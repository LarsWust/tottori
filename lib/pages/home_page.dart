import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tottori/main.dart';
import 'package:tottori/pages/explore.dart';
import 'package:tottori/pages/profile.dart';
import 'package:tottori/pages/search_page.dart';
import 'package:tottori/pages/sign_up_or_in.dart';
import 'package:tottori/pages/table_remote.dart';

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

  int _selectedIndex = 0;
  List<Widget> pages = [
    const Explore(),
    const SearchPage(),
    const Remote(),
    Profile(
      uuid: user!.uid,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
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
      ]),
      bottomNavigationBar: BottomNavigationBar(
        unselectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.outline),
        selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.onBackground),
        selectedItemColor: Theme.of(context).colorScheme.onBackground,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Explore",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.table_bar), label: "My Table"),
          BottomNavigationBarItem(icon: Icon(Icons.perm_identity), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: pages[_selectedIndex],
    );
  }
}
