import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(titleText),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
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
      body: pages[selectedPage],
    );
  }
}
