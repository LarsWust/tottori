import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tottori/classes/tottori_queue.dart';
import 'package:tottori/classes/tottori_queue_data.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:expandable/expandable.dart';
import 'package:tottori/classes/tottori_user_data.dart';
import 'package:tottori/components/box_button.dart';
import 'package:tottori/components/box_button_type.dart';
import 'package:tottori/components/profile_picture.dart';
import 'package:tottori/main.dart';
import 'package:uuid/uuid.dart';

class QueueView extends StatefulWidget {
  TottoriQueueData queueData = TottoriQueue.defaultData;
  int? heroTag;
  ValueNotifier<TottoriQueueData> queueDataNotifier = ValueNotifier<TottoriQueueData>(TottoriQueue.defaultData);
  bool edit = false;

  QueueView.edit({super.key, required this.queueData}) {
    edit = true;
    queueDataNotifier = ValueNotifier<TottoriQueueData>(queueData);
  }
  QueueView.create({super.key}) {
    edit = true;
  }
  QueueView({super.key, required this.queueData, this.heroTag}) {
    queueDataNotifier = ValueNotifier<TottoriQueueData>(queueData);
  }

  @override
  State<QueueView> createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  TextEditingController captionController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  bool recursiveEnabled = true;

  @override
  initState() {
    super.initState();
    titleController = TextEditingController(text: widget.queueData.title);
    captionController = TextEditingController(text: widget.queueData.caption);
  }

  @override
  Widget build(BuildContext context) {
    ScrollController captionScrollController = ScrollController();

    return ValueListenableBuilder(
        valueListenable: widget.queueDataNotifier,
        builder: (context, queueData, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: widget.edit
                                ? Stack(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: widget.heroTag == null
                                            ? queueData.getCoverImage(context)
                                            : Hero(
                                                tag: widget.heroTag!,
                                                child: queueData.getCoverImage(context),
                                              ),
                                      ),
                                      Positioned.fill(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black.withOpacity(0.25),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: PopupMenuButton(
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: "/svg",
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.circle_outlined,
                                                      color: Theme.of(context).colorScheme.onBackground,
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      'Track Thumbnail',
                                                      style: Theme.of(context).textTheme.bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: "/image",
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.image,
                                                      color: Theme.of(context).colorScheme.onBackground,
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      'Image',
                                                      style: Theme.of(context).textTheme.bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onSelected: (value) async {
                                              if (value == "/image") {
                                                final ImagePicker picker = ImagePicker();
                                                final XFile? pick = await picker.pickImage(source: ImageSource.gallery);
                                                if (pick != null) {
                                                  try {
                                                    CroppedFile? croppedFile = await ImageCropper().cropImage(
                                                      sourcePath: pick.path,
                                                      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                                                      cropStyle: CropStyle.rectangle,
                                                      compressFormat: ImageCompressFormat.jpg,
                                                      uiSettings: [
                                                        AndroidUiSettings(
                                                          toolbarTitle: 'Crop Profile Picture',
                                                          toolbarColor: Colors.deepOrange,
                                                          toolbarWidgetColor: Colors.white,
                                                          initAspectRatio: CropAspectRatioPreset.square,
                                                          lockAspectRatio: true,
                                                        ),
                                                        IOSUiSettings(
                                                          title: 'Crop Profile Picture',
                                                          aspectRatioLockEnabled: true,
                                                          minimumAspectRatio: 1,
                                                          aspectRatioPickerButtonHidden: true,
                                                          resetAspectRatioEnabled: false,
                                                        ),
                                                      ],
                                                    );
                                                    if (croppedFile != null) {
                                                      setState(() {
                                                        widget.queueDataNotifier.value.cover = File(croppedFile.path);
                                                        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                                        widget.queueDataNotifier.notifyListeners();
                                                      });
                                                    } else {
                                                      print("crop cancelled");
                                                    }
                                                  } catch (e) {
                                                    print("error picking image");
                                                  }
                                                }
                                              } else if (value == "/svg") {
                                                widget.queueDataNotifier.value.cover = ((await selectTrackQueue(context, selectQueues: false, selectMultiple: false)).first as TottoriTrackData).svg;
                                                // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                                widget.queueDataNotifier.notifyListeners();
                                              }
                                            },
                                            offset: const Offset(50, 0),
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : AspectRatio(
                                    aspectRatio: 1,
                                    child: widget.heroTag == null
                                        ? queueData.getCoverImage(context)
                                        : Hero(
                                            tag: widget.heroTag!,
                                            child: queueData.getCoverImage(context),
                                          ),
                                  ),
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16 - 8, 16, 16, 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: widget.edit
                                      ? [
                                          TextField(
                                            controller: titleController,
                                            style: Theme.of(context).textTheme.headlineSmall,
                                            decoration: const InputDecoration(
                                              hintText: "Title",
                                            ),
                                          ),
                                          TextField(
                                            controller: captionController,
                                            style: Theme.of(context).textTheme.bodySmall,
                                            decoration: const InputDecoration(
                                              hintText: "Caption",
                                            ),
                                          ),
                                        ]
                                      : [
                                          SizedBox(
                                            height: 25,
                                            child: FutureBuilder(
                                              future: widget.queueDataNotifier.value.owner.data,
                                              initialData: TottoriUser.defaultData,
                                              builder: (context, AsyncSnapshot<TottoriUserData> snapshot) {
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    ProfilePicture.image(image: snapshot.data?.pfp),
                                                    Center(
                                                      child: Text(
                                                        " @${snapshot.data?.username}",
                                                        style: Theme.of(context).textTheme.labelMedium,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                          const Divider(height: 16),
                                          Text(
                                            widget.queueDataNotifier.value.title,
                                            style: Theme.of(context).textTheme.headlineSmall,
                                          ),
                                          Expanded(
                                            child: Scrollbar(
                                              controller: captionScrollController,
                                              child: SingleChildScrollView(
                                                controller: captionScrollController,
                                                child: Text(
                                                  widget.queueDataNotifier.value.caption,
                                                  style: Theme.of(context).textTheme.bodySmall,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          "${queueData.length} tracks • ${queueData.readableDistance}",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const Spacer(),
                        widget.edit
                            ? IntrinsicHeight(
                                child: BoxButton(
                                  onTap: () async {
                                    widget.queueDataNotifier.value = await reorderQueueList(context, data: queueData);
                                    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                    widget.queueDataNotifier.notifyListeners();
                                  },
                                  icon: Icons.format_line_spacing,
                                ),
                              )
                            : const SizedBox.shrink(),
                        !widget.edit && widget.queueData.owner.uuid == user?.uid
                            ? IntrinsicHeight(
                                child: BoxButton(
                                  onTap: () async {
                                    setState(() {
                                      widget.edit = true;
                                    });
                                  },
                                  icon: Icons.edit,
                                ),
                              )
                            : const SizedBox.shrink(),
                        IntrinsicHeight(
                          child: BoxButton(
                            onTap: () async {
                              setState(() {
                                recursiveEnabled = !recursiveEnabled;
                              });
                            },
                            icon: recursiveEnabled ? Icons.unfold_less : Icons.unfold_more,
                          ),
                        ),
                        widget.edit
                            ? IntrinsicHeight(
                                child: BoxButton(
                                  onTap: () async {
                                    List<dynamic> addedTracksQueues = await selectTrackQueue(context);
                                    await widget.queueDataNotifier.value.addChildren(addedTracksQueues, expanded: true);

                                    print("Done :)");
                                    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                    widget.queueDataNotifier.notifyListeners();
                                  },
                                  icon: Icons.add,
                                ),
                              )
                            : const SizedBox.shrink(),
                        widget.edit
                            ? IntrinsicHeight(
                                child: BoxButton(
                                  type: BoxButtonType.positive,
                                  onTap: () async {
                                    if (queueData.uid == "") {
                                      String newUuid = const Uuid().v4();
                                      await TottoriQueueData(
                                        title: titleController.text,
                                        caption: captionController.text,
                                        owner: TottoriUser(user!.uid),
                                        uid: newUuid,
                                        created: Timestamp.now(),
                                        edited: null,
                                        children: queueData.getChildren,
                                        length: queueData.length,
                                        distance: queueData.distance,
                                        likes: [],
                                        dependants: [],
                                        cover: queueData.cover,
                                      ).createQueue();
                                    } else {
                                      await TottoriQueue(queueData.uid).setData(queueData);
                                    }
                                    setState(() {
                                      widget.edit = false;
                                    });
                                  },
                                  icon: Icons.check,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  child: Column(
                    children: queueTrackCard(widget.queueDataNotifier.value.getChildren, 10, recursive: recursiveEnabled),
                  ),
                ),
              ),
            ],
          );
        });
  }

  List<Widget> queueTrackCard(List<dynamic> data, int maxDepth, {List<int>? count, int depth = 0, bool recursive = true}) {
    count ??= [0];
    if (data.isEmpty || maxDepth == 0) {
      return [const SizedBox.shrink()];
    }
    String indexText = count.map((element) => element + 1).join(".");
    if (data.first.runtimeType == TottoriTrackData) {
      TottoriTrackData trackData = data.first;
      Widget card = IntrinsicHeight(
        child: Row(
          children: [
            depth > 0
                ? Builder(builder: (context) {
                    List<Widget> dividers = List.generate(
                      depth,
                      (index) {
                        return VerticalDivider(
                          color: Theme.of(context).colorScheme.surface,
                          width: 8,
                          thickness: 1,
                        );
                      },
                      growable: false,
                    );
                    return Row(
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        ...dividers
                      ],
                    );
                  })
                : const SizedBox.shrink(),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10 + ((indexText.length * 8)).toDouble(),
                        child: Text(
                          indexText,
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: trackData.svgPicture(context, expandable: true),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trackData.title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            FutureBuilder(
                              future: trackData.owner.data,
                              initialData: TottoriUser.defaultData,
                              builder: (context, ownerData) {
                                return Text(
                                  "@${ownerData.data?.username} • ${trackData.readableDistance}",
                                  style: Theme.of(context).textTheme.labelSmall,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      depth == 0 && widget.edit
                          ? SizedBox(
                              width: 60,
                              height: 60,
                              child: BoxButton(
                                type: BoxButtonType.warning,
                                icon: Icons.delete,
                                onTap: () async {
                                  await widget.queueDataNotifier.value.removeAt(count!.first);
                                  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                  widget.queueDataNotifier.notifyListeners();
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      return [
        card,
        ...queueTrackCard(data.sublist(1), maxDepth, count: count.toList()..setAll(count.length - 1, [count.last + 1]), depth: depth, recursive: recursive)
      ];
    } else if (data.first.runtimeType == TottoriQueueData) {
      TottoriQueueData nestedQueueData = data.first;
      List<dynamic> nestedQueueChildren = data.first.getChildren;
      Widget card = IntrinsicHeight(
        child: Row(
          children: [
            depth > 0
                ? Builder(builder: (context) {
                    List<Widget> dividers = List.generate(
                      depth,
                      (index) {
                        return VerticalDivider(
                          color: Theme.of(context).colorScheme.surface,
                          width: 8,
                          thickness: 1,
                        );
                      },
                      growable: false,
                    );
                    return Row(
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        ...dividers
                      ],
                    );
                  })
                : const SizedBox.shrink(),
            Expanded(
              child: Card(
                color: Theme.of(context).secondaryHeaderColor,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10 + ((indexText.length * 8)).toDouble(),
                        child: Text(
                          indexText,
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: nestedQueueData.getCoverImage(context, expandable: true),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nestedQueueData.title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            FutureBuilder(
                              future: nestedQueueData.owner.data,
                              initialData: TottoriUser.defaultData,
                              builder: (context, ownerData) {
                                return Text(
                                  "@${ownerData.data?.username} • ${nestedQueueData.readableDistance} • ${nestedQueueData.length} tracks",
                                  style: Theme.of(context).textTheme.labelSmall,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      depth == 0 && widget.edit
                          ? SizedBox(
                              width: 60,
                              height: 60,
                              child: BoxButton(
                                type: BoxButtonType.warning,
                                icon: Icons.delete,
                                onTap: () async {
                                  await widget.queueDataNotifier.value.removeAt(count!.first);
                                  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                  widget.queueDataNotifier.notifyListeners();
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      return recursive
          ? [
              card,
              ...queueTrackCard(nestedQueueChildren, maxDepth - 1, count: count.toList()..add(0), depth: depth + 1, recursive: recursive),
              ...queueTrackCard(data.sublist(1), maxDepth, count: count.toList()..setAll(count.length - 1, [count.last + 1]), depth: depth, recursive: recursive),
            ]
          : [
              card,
              ...queueTrackCard(data.sublist(1), maxDepth, count: count.toList()..setAll(count.length - 1, [count.last + 1]), depth: depth, recursive: recursive),
            ];
    } else {
      return [const SizedBox.shrink()];
    }
  }

  Future<List<dynamic>> selectTrackQueue(BuildContext context, {bool selectTracks = true, bool selectQueues = true, bool selectMultiple = true}) async {
    PageController pageController = PageController();
    ValueNotifier pageNotifier = ValueNotifier<int>(0);
    ValueNotifier<List<dynamic>> selectedNotifier = ValueNotifier([]);
    TextEditingController searchController = TextEditingController();
    FocusNode searchFocus = FocusNode();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: ValueListenableBuilder(
              valueListenable: selectedNotifier,
              builder: (context, selected, child) {
                return StreamBuilder<TottoriUserData>(
                    stream: currentUserDataStream,
                    initialData: TottoriUser.defaultData,
                    builder: (context, userData) {
                      Widget selectTrackView = Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ExpandableNotifier(
                                    //controller: trackExpandController,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        children: [
                                          Card(
                                            child: ExpandablePanel(
                                              theme: ExpandableThemeData(
                                                iconColor: Theme.of(context).colorScheme.outline,
                                                tapHeaderToExpand: true,
                                              ),
                                              header: SizedBox(
                                                height: 40,
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 16.0),
                                                    child: Text(
                                                      "Liked Tracks",
                                                      style: Theme.of(context).textTheme.titleSmall,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              expanded: Flexible(
                                                child: Builder(
                                                  builder: (context) {
                                                    List<Widget> widgets = [];
                                                    for (TottoriTrack track in userData.data?.likedTracks ?? []) {
                                                      widgets.add(FutureBuilder(
                                                          future: track.data,
                                                          builder: (context, trackData) {
                                                            if (searchController.text == "" || trackData.data!.title.toLowerCase().contains(searchController.text)) {
                                                              return Card(
                                                                color: Theme.of(context).secondaryHeaderColor,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 50,
                                                                        height: 50,
                                                                        child: trackData.data?.svgPicture(
                                                                          context,
                                                                          expandable: true,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width: 8,
                                                                      ),
                                                                      Expanded(
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              // maxLines: 1,
                                                                              // softWrap: false,
                                                                              // overflow: TextOverflow.fade,
                                                                              "${trackData.data?.title}",
                                                                              style: Theme.of(context).textTheme.titleSmall,
                                                                            ),
                                                                            FutureBuilder(
                                                                                future: trackData.data?.owner.data,
                                                                                initialData: TottoriUser.defaultData,
                                                                                builder: (context, ownerData) {
                                                                                  return Text(
                                                                                    "@${ownerData.data?.username}",
                                                                                    style: Theme.of(context).textTheme.labelSmall,
                                                                                  );
                                                                                }),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Builder(builder: (context) {
                                                                        bool isSelected = selected
                                                                            .map(
                                                                              (e) => (e.runtimeType == TottoriTrackData) ? (e as TottoriTrackData).tot : null,
                                                                            )
                                                                            .contains(trackData.data!.tot);
                                                                        return IntrinsicHeight(
                                                                          child: BoxButton(
                                                                            type: (isSelected == true) ? BoxButtonType.positive : BoxButtonType.normal,
                                                                            icon: (isSelected == true) ? Icons.check : Icons.add,
                                                                            onTap: () {
                                                                              (isSelected == true)
                                                                                  ? selectedNotifier.value.removeWhere((element) => (element.runtimeType == TottoriTrackData) ? (element as TottoriTrackData).tot == trackData.data!.tot : false)
                                                                                  : selectedNotifier.value.add(trackData.data);
                                                                              // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                                                              selectedNotifier.notifyListeners();
                                                                            },
                                                                          ),
                                                                        );
                                                                      }),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              return const SizedBox.shrink();
                                                            }
                                                          }));
                                                    }

                                                    return Column(
                                                      children: widgets,
                                                    );
                                                  },
                                                ),
                                              ),
                                              collapsed: const SizedBox.shrink(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ExpandableNotifier(
                                    //controller: trackExpandController,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        children: [
                                          Card(
                                            child: ExpandablePanel(
                                              theme: ExpandableThemeData(
                                                iconColor: Theme.of(context).colorScheme.outline,
                                                tapHeaderToExpand: true,
                                              ),
                                              header: SizedBox(
                                                height: 40,
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 16.0),
                                                    child: Text(
                                                      "Owned Tracks",
                                                      style: Theme.of(context).textTheme.titleSmall,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              expanded: Flexible(
                                                child: Builder(
                                                  builder: (context) {
                                                    List<Widget> widgets = [];
                                                    for (TottoriTrack track in userData.data?.ownedTracks ?? []) {
                                                      widgets.add(FutureBuilder(
                                                          future: track.data,
                                                          builder: (context, trackData) {
                                                            return Card(
                                                              color: Theme.of(context).secondaryHeaderColor,
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 50,
                                                                      height: 50,
                                                                      child: trackData.data?.svgPicture(
                                                                        context,
                                                                        expandable: true,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            // maxLines: 1,
                                                                            // softWrap: false,
                                                                            // overflow: TextOverflow.fade,
                                                                            "${trackData.data?.title}",
                                                                            style: Theme.of(context).textTheme.titleSmall,
                                                                          ),
                                                                          FutureBuilder(
                                                                              future: trackData.data?.owner.data,
                                                                              initialData: TottoriUser.defaultData,
                                                                              builder: (context, ownerData) {
                                                                                return Text(
                                                                                  "@${ownerData.data?.username}",
                                                                                  style: Theme.of(context).textTheme.labelSmall,
                                                                                );
                                                                              }),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Builder(builder: (context) {
                                                                      bool isSelected = selected
                                                                          .map(
                                                                            (e) => (e.runtimeType == TottoriTrackData) ? (e as TottoriTrackData).tot : null,
                                                                          )
                                                                          .contains(trackData.data!.tot);
                                                                      return IntrinsicHeight(
                                                                        child: BoxButton(
                                                                          type: (isSelected == true) ? BoxButtonType.positive : BoxButtonType.normal,
                                                                          icon: (isSelected == true) ? Icons.check : Icons.add,
                                                                          onTap: () {
                                                                            (isSelected == true)
                                                                                ? selectedNotifier.value.removeWhere((element) => (element.runtimeType == TottoriTrackData) ? (element as TottoriTrackData).tot == trackData.data!.tot : false)
                                                                                : selectedNotifier.value.add(trackData.data);
                                                                            // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                                                            selectedNotifier.notifyListeners();
                                                                            selectMultiple ? null : Navigator.pop(context);
                                                                          },
                                                                        ),
                                                                      );
                                                                    }),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }));
                                                    }

                                                    return Column(
                                                      children: widgets,
                                                    );
                                                  },
                                                ),
                                              ),
                                              collapsed: const SizedBox.shrink(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 300,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                      Widget selectQueueView = Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ExpandableNotifier(
                                    //controller: trackExpandController,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        children: [
                                          Card(
                                            child: ExpandablePanel(
                                              theme: ExpandableThemeData(
                                                iconColor: Theme.of(context).colorScheme.outline,
                                                tapHeaderToExpand: true,
                                              ),
                                              header: SizedBox(
                                                height: 40,
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 16.0),
                                                    child: Text(
                                                      "Liked Queues",
                                                      style: Theme.of(context).textTheme.titleSmall,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              expanded: Flexible(
                                                child: Builder(
                                                  builder: (context) {
                                                    List<Widget> widgets = [];
                                                    for (TottoriQueue queue in userData.data?.likedQueues ?? []) {
                                                      widgets.add(FutureBuilder(
                                                          future: queue.getData(searchDepth: 1),
                                                          initialData: TottoriQueue.defaultData,
                                                          builder: (context, queueData) {
                                                            if (searchController.text == "" || queueData.data!.title.toLowerCase().contains(searchController.text)) {
                                                              return Card(
                                                                color: Theme.of(context).secondaryHeaderColor,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 50,
                                                                        height: 50,
                                                                        child: queueData.data?.getCoverImage(
                                                                          context,
                                                                          expandable: true,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width: 8,
                                                                      ),
                                                                      Expanded(
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              // maxLines: 1,
                                                                              // softWrap: false,
                                                                              // overflow: TextOverflow.fade,
                                                                              "${queueData.data?.title}",
                                                                              style: Theme.of(context).textTheme.titleSmall,
                                                                            ),
                                                                            FutureBuilder(
                                                                                future: queueData.data?.owner.data,
                                                                                initialData: TottoriUser.defaultData,
                                                                                builder: (context, ownerData) {
                                                                                  return Text(
                                                                                    "@${ownerData.data?.username}",
                                                                                    style: Theme.of(context).textTheme.labelSmall,
                                                                                  );
                                                                                }),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Builder(builder: (context) {
                                                                        bool isSelected = selected
                                                                            .map(
                                                                              (e) => (e.runtimeType == TottoriQueueData) ? (e as TottoriQueueData).uid : null,
                                                                            )
                                                                            .contains(queueData.data!.uid);
                                                                        return IntrinsicHeight(
                                                                          child: BoxButton(
                                                                            type: (isSelected == true) ? BoxButtonType.positive : BoxButtonType.normal,
                                                                            icon: (isSelected == true) ? Icons.check : Icons.add,
                                                                            onTap: () {
                                                                              (isSelected == true)
                                                                                  ? selectedNotifier.value.removeWhere((element) => (element.runtimeType == TottoriQueueData) ? (element as TottoriQueueData).uid == queueData.data!.uid : false)
                                                                                  : selectedNotifier.value.add(queueData.data);
                                                                              // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                                                              selectedNotifier.notifyListeners();
                                                                              selectMultiple ? null : Navigator.pop(context);
                                                                            },
                                                                          ),
                                                                        );
                                                                      }),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              return const SizedBox.shrink();
                                                            }
                                                          }));
                                                    }

                                                    return Column(
                                                      children: widgets,
                                                    );
                                                  },
                                                ),
                                              ),
                                              collapsed: const SizedBox.shrink(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ExpandableNotifier(
                                    //controller: trackExpandController,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        children: [
                                          Card(
                                            child: ExpandablePanel(
                                              theme: ExpandableThemeData(
                                                iconColor: Theme.of(context).colorScheme.outline,
                                                tapHeaderToExpand: true,
                                              ),
                                              header: SizedBox(
                                                height: 40,
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 16.0),
                                                    child: Text(
                                                      "Owned Queues",
                                                      style: Theme.of(context).textTheme.titleSmall,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              expanded: Flexible(
                                                child: Builder(
                                                  builder: (context) {
                                                    List<Widget> widgets = [];
                                                    for (TottoriQueue queue in userData.data?.ownedQueues ?? []) {
                                                      widgets.add(FutureBuilder(
                                                          future: queue.getData(searchDepth: 1),
                                                          initialData: TottoriQueue.defaultData,
                                                          builder: (context, selectQueueData) {
                                                            if (searchController.text == "" || (selectQueueData.data?.title.toLowerCase().contains(searchController.text) ?? false)) {
                                                              return Card(
                                                                color: Theme.of(context).secondaryHeaderColor,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 50,
                                                                        height: 50,
                                                                        child: selectQueueData.data?.getCoverImage(
                                                                          context,
                                                                          expandable: true,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width: 8,
                                                                      ),
                                                                      Expanded(
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              // maxLines: 1,
                                                                              // softWrap: false,
                                                                              // overflow: TextOverflow.fade,
                                                                              selectQueueData.connectionState == ConnectionState.done ? selectQueueData.data?.title ?? "n" : "Loading",
                                                                              style: Theme.of(context).textTheme.titleSmall,
                                                                            ),
                                                                            FutureBuilder(
                                                                                future: selectQueueData.data?.owner.data,
                                                                                initialData: TottoriUser.defaultData,
                                                                                builder: (context, ownerData) {
                                                                                  return Text(
                                                                                    "@${ownerData.data?.username} • ${selectQueueData.data?.readableDistance}",
                                                                                    style: Theme.of(context).textTheme.labelSmall,
                                                                                  );
                                                                                }),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Builder(builder: (context) {
                                                                        bool isSelected = selected
                                                                            .map(
                                                                              (e) => (e.runtimeType == TottoriQueueData) ? (e as TottoriQueueData).uid : null,
                                                                            )
                                                                            .contains(selectQueueData.data?.uid);
                                                                        return IntrinsicHeight(
                                                                          child: BoxButton(
                                                                            type: (isSelected == true) ? BoxButtonType.positive : BoxButtonType.normal,
                                                                            icon: (isSelected == true) ? Icons.check : Icons.add,
                                                                            onTap: () {
                                                                              (isSelected == true)
                                                                                  ? selectedNotifier.value.removeWhere((element) => (element.runtimeType == TottoriQueueData) ? (element as TottoriQueueData).uid == selectQueueData.data?.uid : false)
                                                                                  : selectedNotifier.value.add(selectQueueData.data);
                                                                              // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                                                              selectedNotifier.notifyListeners();
                                                                            },
                                                                          ),
                                                                        );
                                                                      }),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              return const SizedBox.shrink();
                                                            }
                                                          }));
                                                    }

                                                    return Column(
                                                      children: widgets,
                                                    );
                                                  },
                                                ),
                                              ),
                                              collapsed: const SizedBox.shrink(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 300,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                      return Container(
                        //height: 1500,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FractionallySizedBox(
                                widthFactor: 0.3,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.outline,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: pageNotifier,
                              builder: (context, value, child) {
                                return Row(
                                  children: [
                                    selectTracks
                                        ? Flexible(
                                            fit: FlexFit.tight,
                                            child: InkWell(
                                              onTap: () {
                                                pageController.animateToPage(
                                                  0,
                                                  duration: const Duration(milliseconds: 250),
                                                  curve: Curves.easeInOut,
                                                );
                                              },
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Text(
                                                    "Tracks",
                                                    style: value != 0
                                                        ? Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.normal)
                                                        : Theme.of(context).textTheme.titleMedium!, //.copyWith(color: Theme.of(context).colorScheme.outline),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    selectQueues
                                        ? Flexible(
                                            fit: FlexFit.tight,
                                            child: InkWell(
                                              onTap: () {
                                                pageController.animateToPage(
                                                  1,
                                                  duration: const Duration(milliseconds: 250),
                                                  curve: Curves.easeInOut,
                                                );
                                              },
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Text(
                                                    "Queues",
                                                    style: value != 1
                                                        ? Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.normal)
                                                        : Theme.of(context).textTheme.titleMedium!, //.copyWith(color: Theme.of(context).colorScheme.outline),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                              child: TextField(
                                onEditingComplete: () {
                                  searchFocus.unfocus();

                                  setState(() {});
                                },
                                onTapOutside: (event) {
                                  searchFocus.unfocus();
                                },
                                controller: searchController,
                                textInputAction: TextInputAction.search,
                                focusNode: searchFocus,
                                decoration: InputDecoration(
                                  suffixIcon: searchController.text != ""
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            searchController.clear();
                                            searchFocus.unfocus();
                                            setState(() {});
                                          },
                                        )
                                      : const SizedBox.shrink(),
                                  prefixIcon: const Icon(Icons.search),
                                  hintText: "Search",
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                  contentPadding: const EdgeInsets.all(8),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 10,
                                      color: Colors.transparent,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        16,
                                      ),
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 10,
                                      color: Colors.transparent,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: selectTracks && selectQueues
                                  ? PageView(
                                      onPageChanged: (value) {
                                        pageNotifier.value = value;
                                      },
                                      controller: pageController,
                                      children: [
                                        selectTracks ? selectTrackView : const SizedBox.shrink(),
                                        selectQueues ? selectQueueView : const SizedBox.shrink(),
                                      ],
                                    )
                                  : selectTracks
                                      ? selectTrackView
                                      : selectQueues
                                          ? selectQueueView
                                          : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      );
                    });
              }),
        );
      },
    );

    return selectedNotifier.value;
  }
}

Future<TottoriQueueData> reorderQueueList(BuildContext context, {required TottoriQueueData data}) async {
  ValueNotifier<List<dynamic>> childernNotifier = ValueNotifier<List<dynamic>>(data.getChildren);
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.75,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FractionallySizedBox(
                  widthFactor: 0.3,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Center(
                child: Text(
                  "Reorder Queue",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                child: ValueListenableBuilder(
                    valueListenable: childernNotifier,
                    builder: (context, children, _) {
                      return ReorderableListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          for (int i = 0; i < children.length; i++)
                            IntrinsicHeight(
                              key: Key("$i"),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Card(
                                      color: children[i].runtimeType == TottoriTrackData ? Theme.of(context).colorScheme.surface : Theme.of(context).secondaryHeaderColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              child: Text(
                                                (i + 1).toString(),
                                                textAlign: TextAlign.end,
                                                style: Theme.of(context).textTheme.labelSmall,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: children[i].runtimeType == TottoriTrackData ? (children[i] as TottoriTrackData).svgPicture(context, expandable: true) : (children[i] as TottoriQueueData).getCoverImage(context, expandable: true),
                                            ),
                                            const SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    children[i].runtimeType == TottoriTrackData ? (children[i] as TottoriTrackData).title : (children[i] as TottoriQueueData).title,
                                                    style: Theme.of(context).textTheme.titleSmall,
                                                  ),
                                                  FutureBuilder(
                                                    future: children[i].runtimeType == TottoriTrackData ? (children[i] as TottoriTrackData).owner.data : (children[i] as TottoriQueueData).owner.data,
                                                    initialData: TottoriUser.defaultData,
                                                    builder: (context, ownerData) {
                                                      return Text(
                                                        "@${ownerData.data?.username}",
                                                        style: Theme.of(context).textTheme.labelSmall,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.drag_handle,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                            const SizedBox(
                                              width: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ],
                        onReorder: (int oldIndex, int newIndex) {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final dynamic item = childernNotifier.value.removeAt(oldIndex);
                          childernNotifier.value.insert(newIndex, item);
                          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                          childernNotifier.notifyListeners();
                        },
                      );
                    }),
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      );
    },
  );
  data.setChildren(childernNotifier.value);
  return data;
}
