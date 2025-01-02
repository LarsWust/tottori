import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_queue.dart';
import 'package:tottori/classes/tottori_queue_data.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/classes/tottori_user_data.dart';
import 'package:tottori/components/box_button.dart';
import 'package:tottori/components/box_button_type.dart';
import 'package:tottori/components/keep_alive_page.dart';
import 'package:tottori/components/profile_picture.dart';
import 'package:tottori/components/selectors/selectors.dart';
import 'package:tottori/components/user_list.dart';
import 'package:tottori/helpers/navigation_helpers.dart';
import 'package:tottori/main.dart';
import 'package:tottori/pages/profile_setup.dart';
import 'package:expandable/expandable.dart';

class ProfileCard extends StatefulWidget {
  final TottoriUser tottoriUser;
  TottoriUserData? data;
  ProfileCard(this.tottoriUser, {super.key, this.data});

  @override
  State<ProfileCard> createState() => _ProfileCardState();

  Stream<TottoriUserData> getData() {
    if (data != null) {
      return Stream.value(data!);
    } else {
      if (tottoriUser.uuid == user?.uid) {
        return currentUserDataStream;
      }
      return tottoriUser.dataStream;
    }
  }
}

class _ProfileCardState extends State<ProfileCard> {
  PageController pageController = PageController(initialPage: 0);
  ValueNotifier pageNotifier = ValueNotifier<int>(0);
  ValueNotifier selectedNotifier = ValueNotifier<List<dynamic>>([]);
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  bool selectMultiple = true;
  bool selectQueues = true;
  bool selectTracks = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.getData(),
      initialData: widget.tottoriUser.uuid == user?.uid ? currentUserData : null,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 75,
                            height: 75,
                            child: ProfilePicture.image(
                              image: snapshot.data!.pfp,
                              expanable: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot.data!.displayName,
                                            style: Theme.of(context).textTheme.titleMedium!,
                                          ),
                                          Text(
                                            "@${snapshot.data!.username}",
                                            style: Theme.of(context).textTheme.bodySmall!,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                                          builder: (context) => const ProfileSetupPage(),
                                        ));
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        color: Theme.of(context).colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => TottoriUserList(users: snapshot.data!.followers, title: "${snapshot.data!.displayName}'s Followers"),
                                        ));
                                      },
                                      child: Column(
                                        children: [
                                          Text(
                                            "${snapshot.data!.followers.length}",
                                            style: Theme.of(context).textTheme.labelLarge,
                                          ),
                                          Text(
                                            "Followers",
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => TottoriUserList(users: snapshot.data!.following, title: "${snapshot.data!.displayName}'s Follows"),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          Text(
                                            "${snapshot.data!.following.length}",
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                          Text(
                                            "Following",
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      color: Theme.of(context).textTheme.labelMedium!.color,
                                      size: Theme.of(context).textTheme.labelMedium!.fontSize! * 1.25,
                                    ),
                                    Builder(
                                      builder: (context) {
                                        DateTime date = snapshot.data!.created.toDate();
                                        String month;
                                        switch (date.month) {
                                          case 1:
                                            month = "Janurary";
                                            break;
                                          case 2:
                                            month = "February";
                                            break;
                                          case 3:
                                            month = "March";
                                            break;
                                          case 4:
                                            month = "April";
                                            break;
                                          case 5:
                                            month = "May";
                                            break;
                                          case 6:
                                            month = "June";
                                            break;
                                          case 7:
                                            month = "July";
                                            break;
                                          case 8:
                                            month = "August";
                                            break;
                                          case 9:
                                            month = "September";
                                            break;
                                          case 10:
                                            month = "October";
                                            break;
                                          case 11:
                                            month = "November";
                                            break;
                                          case 12:
                                            month = "December";
                                            break;
                                          default:
                                            month = "???";
                                        }
                                        return Text(
                                          "$month-${date.day.toString()}-${date.year.toString()}",
                                          style: Theme.of(context).textTheme.labelMedium,
                                        );
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      widget.tottoriUser.uuid == user!.uid
                          ? const SizedBox.shrink()
                          : Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    if (snapshot.data!.followers.map((element) => element.uuid).contains(user!.uid)) {
                                      await TottoriUser(user!.uid).unfollowUser(widget.tottoriUser);
                                    } else {
                                      await TottoriUser(user!.uid).followUser(widget.tottoriUser);
                                    }
                                    widget.data = null;
                                    setState(() {});
                                  },
                                  label: Text(snapshot.data!.followers.map((element) => element.uuid).contains(user!.uid) ? "Unfollow" : "Follow"),
                                  icon: Icon(snapshot.data!.followers.map((element) => element.uuid).contains(user!.uid) ? Icons.remove : Icons.add),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.background),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: ValueListenableBuilder(
                    valueListenable: selectedNotifier,
                    builder: (context, selected, child) {
                      return StreamBuilder<TottoriUserData>(
                          stream: widget.tottoriUser.uuid == user?.uid ? currentUserDataStream : widget.tottoriUser.dataStream,
                          initialData: TottoriUser.defaultData,
                          builder: (context, userData) {
                            Widget selectTrackView = Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        ExpandableNotifier(
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
                                                      child: Column(
                                                        children: (snapshot.data?.likedTracks ?? [])
                                                            .map(
                                                              (TottoriTrack track) {
                                                                return FutureBuilder(
                                                                  key: Key("${Random().nextDouble()}"),
                                                                  future: track.data,
                                                                  initialData: TottoriTrack.defaultData,
                                                                  builder: (context, trackData) {
                                                                    return (trackData.data?.title.contains(searchController.text) ?? false)
                                                                        ? Card(
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
                                                                                        ) ??
                                                                                        const SizedBox.shrink(),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 8,
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: InkWell(
                                                                                      onTap: () {
                                                                                        pushTrackCard(context, heroTag: trackData.data?.svg.hashCode, trackData: trackData.data!);
                                                                                      },
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            "${trackData.data?.title}",
                                                                                            style: Theme.of(context).textTheme.titleSmall,
                                                                                          ),
                                                                                          FutureBuilder(
                                                                                              future: trackData.data?.owner.data,
                                                                                              initialData: TottoriUser.defaultData,
                                                                                              builder: (context, ownerData) {
                                                                                                return Text(
                                                                                                  "@${ownerData.data?.username ?? ""} • ${trackData.data?.readableDistance}",
                                                                                                  style: Theme.of(context).textTheme.labelSmall,
                                                                                                );
                                                                                              }),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  IntrinsicHeight(
                                                                                    child: BoxButton(
                                                                                      type: BoxButtonType.normal,
                                                                                      icon: Icons.add,
                                                                                      onTap: () async {
                                                                                        if (trackData.connectionState != ConnectionState.waiting) {
                                                                                          List<TottoriQueueData> toAdd = await selectAddingQueues(context);
                                                                                          for (TottoriQueueData addQueueData in toAdd) {
                                                                                            TottoriQueue(addQueueData.uid).addTrack(trackData.data!);
                                                                                          }
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : const SizedBox.shrink();
                                                                  },
                                                                );
                                                              },
                                                            )
                                                            .toList()
                                                            .cast<Widget>(),
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
                                                      child: Column(
                                                        children: (snapshot.data?.ownedTracks ?? [])
                                                            .map(
                                                              (TottoriTrack track) {
                                                                return FutureBuilder(
                                                                  key: Key("${Random().nextDouble()}"),
                                                                  future: track.data,
                                                                  initialData: TottoriTrack.defaultData,
                                                                  builder: (context, trackData) {
                                                                    return (trackData.data?.title.contains(searchController.text) ?? false)
                                                                        ? Card(
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
                                                                                        ) ??
                                                                                        const SizedBox.shrink(),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 8,
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: InkWell(
                                                                                      onTap: () {
                                                                                        pushTrackCard(context, heroTag: trackData.data?.svg.hashCode, trackData: trackData.data!);
                                                                                      },
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            "${trackData.data?.title}",
                                                                                            style: Theme.of(context).textTheme.titleSmall,
                                                                                          ),
                                                                                          Text(
                                                                                            "${trackData.data?.readableDistance}",
                                                                                            style: Theme.of(context).textTheme.labelSmall,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  IntrinsicHeight(
                                                                                    child: BoxButton(
                                                                                      type: BoxButtonType.normal,
                                                                                      icon: Icons.add,
                                                                                      onTap: () async {
                                                                                        if (trackData.connectionState != ConnectionState.waiting) {
                                                                                          List<TottoriQueueData> toAdd = await selectAddingQueues(context);
                                                                                          for (TottoriQueueData addQueueData in toAdd) {
                                                                                            TottoriQueue(addQueueData.uid).addTrack(trackData.data!);
                                                                                          }
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : const SizedBox.shrink();
                                                                  },
                                                                );
                                                              },
                                                            )
                                                            .toList()
                                                            .cast<Widget>(),
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
                                                      child: Column(
                                                        children: (snapshot.data?.likedQueues ?? [])
                                                            .map(
                                                              (TottoriQueue queue) {
                                                                return FutureBuilder(
                                                                  key: Key("${Random().nextDouble()}"),
                                                                  future: queue.getData(searchDepth: 1),
                                                                  initialData: TottoriQueue.defaultData,
                                                                  builder: (context, queueData) {
                                                                    return (queueData.data?.title.contains(searchController.text) ?? false)
                                                                        ? Card(
                                                                            color: Theme.of(context).secondaryHeaderColor,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Row(
                                                                                children: [
                                                                                  SizedBox(
                                                                                    width: 50,
                                                                                    height: 50,
                                                                                    child: queueData.data?.getCoverImage(context, expandable: true, heroTag: queueData.data?.cover.hashCode) ?? const SizedBox.shrink(),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 8,
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: InkWell(
                                                                                      onTap: () {
                                                                                        pushQueueView(context, heroTag: queueData.data?.cover.hashCode, queueData: queueData.data!);
                                                                                      },
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            "${queueData.data?.title}",
                                                                                            style: Theme.of(context).textTheme.titleSmall,
                                                                                          ),
                                                                                          FutureBuilder(
                                                                                              future: queueData.data?.owner.data,
                                                                                              initialData: TottoriUser.defaultData,
                                                                                              builder: (context, ownerData) {
                                                                                                return Text(
                                                                                                  "@${ownerData.data?.username ?? ""} • ${queueData.data?.readableDistance} • ${queueData.data?.length} tracks",
                                                                                                  style: Theme.of(context).textTheme.labelSmall,
                                                                                                );
                                                                                              }),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : const SizedBox.shrink();
                                                                  },
                                                                );
                                                              },
                                                            )
                                                            .toList()
                                                            .cast<Widget>(),
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
                                                      child: Column(
                                                        children: (snapshot.data?.ownedQueues ?? [])
                                                            .map(
                                                              (TottoriQueue queue) {
                                                                return FutureBuilder(
                                                                  key: Key("${Random().nextDouble()}"),
                                                                  future: queue.getData(searchDepth: 10),
                                                                  initialData: TottoriQueue.defaultData,
                                                                  builder: (context, queueData) {
                                                                    return (queueData.data?.title.contains(searchController.text) ?? false)
                                                                        ? Card(
                                                                            color: Theme.of(context).secondaryHeaderColor,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Row(
                                                                                children: [
                                                                                  SizedBox(
                                                                                    width: 50,
                                                                                    height: 50,
                                                                                    child: queueData.data?.getCoverImage(context, expandable: true, heroTag: queueData.data?.cover.hashCode) ?? const SizedBox.shrink(),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 8,
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: InkWell(
                                                                                      onTap: () {
                                                                                        pushQueueView(context, heroTag: queueData.data?.cover.hashCode, queueData: queueData.data!);
                                                                                      },
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            "${queueData.data?.title}",
                                                                                            style: Theme.of(context).textTheme.titleSmall,
                                                                                          ),
                                                                                          Text(
                                                                                            "${queueData.data?.readableDistance} • ${queueData.data?.length} tracks",
                                                                                            style: Theme.of(context).textTheme.labelSmall,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : const SizedBox.shrink();
                                                                  },
                                                                );
                                                              },
                                                            )
                                                            .toList()
                                                            .cast<Widget>(),
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
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
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
                                            selectTracks ? KeepAlivePage(child: selectTrackView) : const SizedBox.shrink(),
                                            selectQueues ? KeepAlivePage(child: selectQueueView) : const SizedBox.shrink(),
                                          ],
                                        )
                                      : selectTracks
                                          ? selectTrackView
                                          : selectQueues
                                              ? selectQueueView
                                              : const SizedBox.shrink(),
                                ),
                              ],
                            );
                          });
                    }),
              )
              // ValueListenableBuilder(
              //   valueListenable: pageNotifier,
              //   builder: (context, value, child) {
              //     return Row(
              //       children: [
              //         Flexible(
              //           fit: FlexFit.tight,
              //           child: InkWell(
              //             onTap: () {
              //               pageController.animateToPage(
              //                 0,
              //                 duration: const Duration(milliseconds: 250),
              //                 curve: Curves.easeInOut,
              //               );
              //             },
              //             child: Center(
              //               child: Padding(
              //                 padding: const EdgeInsets.symmetric(vertical: 8.0),
              //                 child: Text(
              //                   "Tracks",
              //                   style: value != 0
              //                       ? Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.normal)
              //                       : Theme.of(context).textTheme.titleMedium!, //.copyWith(color: Theme.of(context).colorScheme.outline),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //         Flexible(
              //           fit: FlexFit.tight,
              //           child: InkWell(
              //             onTap: () {
              //               pageController.animateToPage(
              //                 1,
              //                 duration: const Duration(milliseconds: 250),
              //                 curve: Curves.easeInOut,
              //               );
              //             },
              //             child: Center(
              //               child: Padding(
              //                 padding: const EdgeInsets.symmetric(vertical: 8.0),
              //                 child: Text(
              //                   "Queues",
              //                   style: value != 1
              //                       ? Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.normal)
              //                       : Theme.of(context).textTheme.titleMedium!, //.copyWith(color: Theme.of(context).colorScheme.outline),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //         Flexible(
              //           fit: FlexFit.tight,
              //           child: InkWell(
              //             onTap: () {
              //               pageController.animateToPage(
              //                 2,
              //                 duration: const Duration(milliseconds: 250),
              //                 curve: Curves.easeInOut,
              //               );
              //             },
              //             child: Center(
              //               child: Padding(
              //                 padding: const EdgeInsets.symmetric(vertical: 8.0),
              //                 child: Text(
              //                   "Likes",
              //                   style: value != 2
              //                       ? Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.normal)
              //                       : Theme.of(context).textTheme.titleMedium!, //.copyWith(color: Theme.of(context).colorScheme.outline),
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     );
              //   },
              // ),
              // Flexible(
              //   child: PageView(
              //     onPageChanged: (value) {
              //       pageNotifier.value = value;
              //     },
              //     controller: pageController,
              //     children: [
              //       SingleChildScrollView(
              //         child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              //           return Stack(children: [
              //             GridView.builder(
              //               physics: const NeverScrollableScrollPhysics(),
              //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1, mainAxisSpacing: (constraints.maxWidth / 3) * (sqrt(3) - 1)),
              //               itemCount: (3 * ((snapshot.data!.ownedTracks.length + 1) / 5).floor() + max((snapshot.data!.ownedTracks.length + 1) % 5, 1) - 1).toInt(),
              //               shrinkWrap: true,
              //               itemBuilder: (context, index) {
              //                 return TrackPreview(
              //                   track: snapshot.data!.ownedTracks[5 * (index / 3).floor() + (index % 3)],
              //                   expandable: true,
              //                   currentUser: snapshot.data,
              //                 );
              //               },
              //             ),
              //             TransparentPointer(
              //               child: Column(
              //                 children: [
              //                   Container(
              //                     height: constraints.maxWidth * sqrt(3) / 6,
              //                   ),
              //                   Row(
              //                     mainAxisSize: MainAxisSize.min,
              //                     children: [
              //                       Flexible(
              //                         flex: 1,
              //                         child: Container(),
              //                       ),
              //                       Flexible(
              //                         flex: 4,
              //                         child: GridView.builder(
              //                           physics: const NeverScrollableScrollPhysics(),
              //                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1, mainAxisSpacing: (constraints.maxWidth / 3) * (sqrt(3) - 1)),
              //                           itemCount: (2 * ((snapshot.data!.ownedTracks.length - 1) / 5).floor() + max((snapshot.data!.ownedTracks.length - 1) % 5, 2) - 2).toInt(),
              //                           shrinkWrap: true,
              //                           itemBuilder: (context, index) {
              //                             print("length ${snapshot.data!.ownedTracks.length}");
              //                             print("index: ${snapshot.data!.ownedTracks[index].uuid}");
              //                             return TrackPreview(
              //                               track: snapshot.data!.ownedTracks[5 * (index / 2).floor() + (index % 2) + 3],
              //                               expandable: true,
              //                               currentUser: snapshot.data,
              //                             );
              //                           },
              //                         ),
              //                       ),
              //                       Flexible(
              //                         flex: 1,
              //                         child: Container(),
              //                       ),
              //                     ],
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ]);
              //         }),
              //       ),
              //       SingleChildScrollView(
              //         child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              //           return Stack(children: [
              //             GridView.builder(
              //               physics: const NeverScrollableScrollPhysics(),
              //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1, mainAxisSpacing: (constraints.maxWidth / 3) * (sqrt(3) - 1)),
              //               itemCount: (3 * ((snapshot.data!.ownedowneTracks.length + 1) / 5).floor() + max((snapshot.data!.ownedTracks.length + 1) % 5, 1) - 1).toInt(),
              //               shrinkWrap: true,
              //               itemBuilder: (context, index) {
              //                 return TrackPreview(
              //                   track: snapshot.data!.ownedTracks[5 * (index / 3).floor() + (index % 3)],
              //                   expandable: true,
              //                   currentUser: snapshot.data,
              //                 );
              //               },
              //             ),
              //             TransparentPointer(
              //               child: Column(
              //                 children: [
              //                   Container(
              //                     height: constraints.maxWidth * sqrt(3) / 6,
              //                   ),
              //                   Row(
              //                     mainAxisSize: MainAxisSize.min,
              //                     children: [
              //                       Flexible(
              //                         flex: 1,
              //                         child: Container(),
              //                       ),
              //                       Flexible(
              //                         flex: 4,
              //                         child: GridView.builder(
              //                           physics: const NeverScrollableScrollPhysics(),
              //                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1, mainAxisSpacing: (constraints.maxWidth / 3) * (sqrt(3) - 1)),
              //                           itemCount: (2 * ((snapshot.data!.ownedTracks.length - 1) / 5).floor() + max((snapshot.data!.ownedTracks.length - 1) % 5, 2) - 2).toInt(),
              //                           shrinkWrap: true,
              //                           itemBuilder: (context, index) {
              //                             print("length ${snapshot.data!.ownedTracks.length}");
              //                             print("index: ${snapshot.data!.ownedTracks[index].uuid}");
              //                             return TrackPreview(
              //                               track: snapshot.data!.ownedTracks[5 * (index / 2).floor() + (index % 2) + 3],
              //                               expandable: true,
              //                               currentUser: snapshot.data,
              //                             );
              //                           },
              //                         ),
              //                       ),
              //                       Flexible(
              //                         flex: 1,
              //                         child: Container(),
              //                       ),
              //                     ],
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ]);
              //         }),
              //       ),
              //       SingleChildScrollView(
              //         child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              //           return Stack(children: [
              //             GridView.builder(
              //               physics: const NeverScrollableScrollPhysics(),
              //               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1, mainAxisSpacing: (constraints.maxWidth / 3) * (sqrt(3) - 1)),
              //               itemCount: (3 * ((snapshot.data!.likedTracks.length + 1) / 5).floor() + max((snapshot.data!.likedTracks.length + 1) % 5, 1) - 1).toInt(),
              //               shrinkWrap: true,
              //               itemBuilder: (context, index) {
              //                 return TrackPreview(
              //                   track: snapshot.data!.likedTracks[5 * (index / 3).floor() + (index % 3)],
              //                   expandable: true,
              //                   currentUser: snapshot.data,
              //                   whoLiked: widget.user,
              //                 );
              //               },
              //             ),
              //             TransparentPointer(
              //               child: Column(
              //                 children: [
              //                   Container(
              //                     height: constraints.maxWidth * sqrt(3) / 6,
              //                   ),
              //                   Row(
              //                     mainAxisSize: MainAxisSize.min,
              //                     children: [
              //                       Flexible(
              //                         flex: 1,
              //                         child: Container(),
              //                       ),
              //                       Flexible(
              //                         flex: 4,
              //                         child: GridView.builder(
              //                           physics: const NeverScrollableScrollPhysics(),
              //                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1, mainAxisSpacing: (constraints.maxWidth / 3) * (sqrt(3) - 1)),
              //                           itemCount: (2 * ((snapshot.data!.likedTracks.length - 1) / 5).floor() + max((snapshot.data!.likedTracks.length - 1) % 5, 2) - 2).toInt(),
              //                           shrinkWrap: true,
              //                           itemBuilder: (context, index) {
              //                             print("length ${snapshot.data!.likedTracks.length}");
              //                             print("index: ${snapshot.data!.likedTracks[index].uuid}");
              //                             return TrackPreview(
              //                               track: snapshot.data!.likedTracks[5 * (index / 2).floor() + (index % 2) + 3],
              //                               expandable: true,
              //                               currentUser: snapshot.data,
              //                               whoLiked: widget.user,
              //                             );
              //                           },
              //                         ),
              //                       ),
              //                       Flexible(
              //                         flex: 1,
              //                         child: Container(),
              //                       ),
              //                     ],
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ]);
              //         }),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          );
        } else {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfilePicture.blank(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Loading...",
                                style: Theme.of(context).textTheme.headlineSmall!,
                              ),
                              Text(
                                "@tottori.user",
                                style: Theme.of(context).textTheme.bodyMedium!,
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "-",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                      Text(
                                        "Followers",
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "-",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                      Text(
                                        "Following",
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
