import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:tottori/classes/tottori_queue_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/main.dart';
import 'package:tottori/pages/home_page.dart';
import 'package:tottori/pages/sign_up_or_in.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            user = snapshot.data!;
            currentUserDataStream = TottoriUser(user!.uid).dataStream;
            print("oink2");
            currentUserDataStream.listen((event) {
              if (!(event.following.every((element) => currentUserData.followers.map((e) => e.uuid).contains(element.uuid)))) {
                print("Starting search 1");
                TottoriUser(user!.uid).trackFeed(0, 10).then((value) {
                  currentFeedListenable.value = value;
                  currentFeedListenable.notifyListeners();
                  print("Ending search 1");
                });
              }
              if (!(event.ownedQueues.every((element) => currentUserData.ownedQueues.map((e) => e.uuid).contains(element.uuid)))) {
                print("Starting search 2");
                Future.wait(event.ownedQueues.map((e) {
                  print("mapping ${e.uuid}");
                  return e.getData();
                })).then((value) {
                  print("Ending search 2");
                  currentUserOwnedQueues = value;
                });

                // .then((value) {
                //   currentUserOwnedQueues = value;
                //   print("Ending search 2");
                // });
              }
              currentUserData = event;
            });
            DocumentReference doc = FirebaseFirestore.instance.collection("users").doc(user?.uid);
            final username = doc.get().then((value) {
              if (value.exists && value.data() != null) {
                return (value.data() as Map<String, dynamic>)["username"] ?? user?.displayName;
              } else {
                return user?.displayName;
              }
            });
            doc.set({
              "displayName": user?.displayName,
              "username": username,
            });
            print("grahhh $loggedIn");
            if (loggedIn == false) {
              return const AuthToggle();
            } else {
              return const HomePage();
            }
          } else {
            return const AuthToggle();
          }
        },
      ),
    );
  }
}
