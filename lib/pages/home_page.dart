import 'dart:math';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tottori/main.dart';
import 'package:tottori/pages/explore.dart';
import 'package:tottori/pages/profile.dart';
import 'package:tottori/pages/search_page.dart';
import 'package:tottori/pages/sign_up_or_in.dart';
import 'package:tottori/pages/table_remote.dart';
import 'package:tottori/pages/upload_track_page.dart';

int selectedPage = 0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double sheetExtent = 0;
  PanelController panelController = PanelController();

  Future<void> signUserOut() async {
    print("presignout ${user?.uid}");
    await FirebaseAuth.instance.signOut();
    user = FirebaseAuth.instance.currentUser;
    user?.reload();
    print("postsignout ${user?.uid}");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthToggle()));
    loggedIn = false;
    print("set loggedIn to $loggedIn");
  }

  List<Widget> pages = [
    const Explore(),
    const SearchPage(),
    const UploadPage(),
    const Remote(),
    Profile(uuid: user!.uid, data: currentUserData),
  ];

  @override
  Widget build(BuildContext context) {
    String titleText = "";
    switch (selectedPage) {
      case 0:
        titleText = "Explore";
        break;
      case 1:
        titleText = "Search Users";
        break;
      case 2:
        titleText = "Upload Tracks";
        break;
      case 3:
        titleText = "Table Remote";
        break;
      case 4:
        titleText = "Your Profile";
        break;
    }
    return ValueListenableBuilder(
        valueListenable: currentTable.isConnectedNotifier,
        builder: (context, isConnected, _) {
          return SlidingUpPanel(
              backdropEnabled: true,
              renderPanelSheet: false,
              controller: panelController,
              onPanelSlide: (position) {
                setState(() {
                  sheetExtent = position;
                });
              },
              minHeight: 75 + kBottomNavigationBarHeight + MediaQuery.of(context).viewPadding.bottom,
              maxHeight: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(
                bottom: (1 - sheetExtent) * (kBottomNavigationBarHeight + MediaQuery.of(context).viewPadding.bottom),
              ),
              collapsed: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: themeNotifier.value == ThemeMode.dark ? Colors.black26 : Colors.grey,
                      ),
                    ],
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  margin: EdgeInsets.only(
                    bottom: kBottomNavigationBarHeight + MediaQuery.of(context).viewPadding.bottom,
                  ),
                  child: Center(
                    child: isConnected
                        ? GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              panelController.open();
                            },
                            child: StreamBuilder(
                              stream: currentTable.dataStream,
                              initialData: currentTable.data,
                              builder: (context, snapshot) {
                                bool trackAvailable = snapshot.data?.currentTrack != null;
                                return snapshot.connectionState == ConnectionState.waiting
                                    ? const CircularProgressIndicator()
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                                                  child: snapshot.data!.currentTrackData != null
                                                      ? AspectRatio(
                                                          aspectRatio: 1,
                                                          child: snapshot.data!.currentTrackData!.svgPicture(context),
                                                        )
                                                      : const AspectRatio(
                                                          aspectRatio: 1,
                                                          child: Placeholder(),
                                                        ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        snapshot.data!.currentTrackData?.title ?? "Unknown",
                                                        style: Theme.of(context).textTheme.bodyLarge,
                                                      ),
                                                      FutureBuilder(
                                                        future: snapshot.data!.currentTrackData?.owner.data,
                                                        builder: (context, owner) {
                                                          return Text(
                                                            owner.data?.displayName ?? "Unknown",
                                                            style: Theme.of(context).textTheme.labelSmall,
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(height: 4),
                                                    ],
                                                  ),
                                                ),
                                                trackAvailable ? IconButton(onPressed: () => currentTable.togglePlay(), icon: Icon(snapshot.data!.isPlaying ? Icons.pause : Icons.play_arrow)) : const SizedBox.shrink(),
                                                const SizedBox(
                                                  width: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: Container(
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.125),
                                              ),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: FractionallySizedBox(
                                                  widthFactor: snapshot.data?.currentTrackData?.distance != null ? ((snapshot.data?.trackProgress ?? 0) / snapshot.data!.currentTrackData!.distance) : 0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.25),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                              },
                            ),
                          )
                        : Text(
                            "Table Not Connected!",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                  ),
                ),
              ),
              panel: Opacity(
                opacity: pow(sheetExtent, 0.3).toDouble(),
                child: Container(
                  color: Colors.white,
                  child: SafeArea(
                    child: StreamBuilder(
                        stream: currentTable.dataStream,
                        initialData: currentTable.data,
                        builder: (context, snapshot) {
                          bool trackAvailable = snapshot.data?.currentTrack != null;
                          return snapshot.connectionState == ConnectionState.waiting
                              ? const CircularProgressIndicator()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          const Flexible(flex: 1, fit: FlexFit.tight, child: SizedBox()),
                                          Text(
                                            currentTable.name ?? "Unknown",
                                            style: Theme.of(context).textTheme.labelLarge,
                                          ),
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: IconButton(
                                                  onPressed: () => panelController.close(),
                                                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                                      child: snapshot.data!.currentTrackData != null
                                          ? AspectRatio(
                                              aspectRatio: 1,
                                              child: InteractiveViewer(child: snapshot.data!.currentTrackData!.svgPicture(context)),
                                            )
                                          : const AspectRatio(
                                              aspectRatio: 1,
                                              child: Placeholder(),
                                            ),
                                    ),
                                    Text(
                                      snapshot.data!.currentTrackData?.title ?? "Unknown",
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    FutureBuilder(
                                      future: snapshot.data!.currentTrackData?.owner.data,
                                      builder: (context, owner) {
                                        return Text(
                                          snapshot.data!.downloadProgress != -1 ? "Downloading (${100 * snapshot.data!.downloadProgress}%)" : (owner.data?.displayName ?? "Unknown"),
                                          style: Theme.of(context).textTheme.labelSmall,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      height: 4,
                                      width: 256,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.125),
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: FractionallySizedBox(
                                          widthFactor: snapshot.data?.currentTrackData?.distance != null ? ((snapshot.data?.trackProgress ?? 0) / snapshot.data!.currentTrackData!.distance) : 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: snapshot.data!.downloadProgress != -1 ? Theme.of(context).colorScheme.primary.withOpacity(0.5) : Theme.of(context).colorScheme.onBackground.withOpacity(0.25),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    trackAvailable
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              IconButton(iconSize: 32, onPressed: () => currentTable.togglePlay(), icon: const Icon(Icons.fast_rewind_rounded)),
                                              const SizedBox(width: 24),
                                              IconButton(iconSize: 32, onPressed: () => currentTable.togglePlay(), icon: Icon(snapshot.data!.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded)),
                                              const SizedBox(width: 24),
                                              IconButton(iconSize: 32, onPressed: () => currentTable.togglePlay(), icon: const Icon(Icons.fast_forward_rounded)),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                  ],
                                );
                        }),
                  ),
                ),
              ),
              body: Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  elevation: 0,
                  centerTitle: true,
                  title: Text(titleText),
                  actions: [
                    IconButton(
                      onPressed: () {
                        themeNotifier.value = themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                      },
                      icon: const Icon(Icons.sunny),
                    ),
                    IconButton(
                      onPressed: () async {
                        await signUserOut();
                      },
                      icon: const Icon(Icons.logout),
                    )
                  ],
                ),
                bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  unselectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.outline),
                  selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.onBackground),
                  selectedItemColor: Theme.of(context).colorScheme.onBackground,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Explore"),
                    BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
                    BottomNavigationBarItem(icon: Icon(Icons.add), label: "Upload"),
                    BottomNavigationBarItem(icon: Icon(Icons.table_bar), label: "My Table"),
                    BottomNavigationBarItem(icon: Icon(Icons.perm_identity), label: "Profile"),
                  ],
                  currentIndex: selectedPage,
                  onTap: (index) {
                    setState(() {
                      selectedPage = index;
                    });
                  },
                ),
                body: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: pages[selectedPage],
                      ),
                      const SizedBox(
                        height: 75 - 8 * 2,
                      ),
                    ],
                  ),
                ),
              ));
        });
  }
}
