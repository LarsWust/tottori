import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_user_data.dart';
import 'package:tottori/helpers/account_helpers.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class TottoriUser {
  late final String uuid;
  late final DocumentReference<Map<String, dynamic>> userDoc = FirebaseFirestore.instance.collection("users").doc(uuid);
  static final RegExp usernameRegExp = RegExp("[0-9a-zA-Z\\._]");
  final Map<String, dynamic> defaultData = {
    "username": "tottori.user",
    "displayName": "Tottori User",
    "lowerCaseUsername": "tottori.user",
    "lowerCaseDisplayName": "tottori user",
    "pfp": Image.asset("lib/assets/default_picture.png"),
    "created": Timestamp.fromMillisecondsSinceEpoch(0),
    "followers": [],
    "following": [],
    "ownedTracks": [],
  };

  TottoriUser(String uuid) {
    this.uuid = uuid.trim();
  }

  Future<TottoriUserData> get data async {
    Map<String, dynamic> userData = await userDoc.get().then((value) {
      if (value.exists && value.data() != null) {
        return (value.data() as Map<String, dynamic>);
      } else {
        return defaultData;
      }
    });
    String pfpPath = 'user-profile-images/$uuid.jpg';
    final ref = FirebaseStorage.instance.ref().child(pfpPath);

    return TottoriUserData(
      displayName: userData["displayName"] ?? defaultData["displayName"],
      username: userData["username"] ?? defaultData["username"],
      pfp: await ref.getDownloadURL().then((uri) => Image.network(uri)).onError((error, stackTrace) => defaultData["pfp"]),
      created: userData["created"] ?? defaultData["created"],
      ownedTracks: (userData["ownedTracks"] ?? defaultData["ownedTracks"]).map((e) => TottoriTrack(e.toString())).toList().cast<TottoriTrack>(),
      followers: (userData["followers"] ?? defaultData["followers"]).map((e) => TottoriUser(e.toString())).toList().cast<TottoriUser>(),
      following: (userData["following"] ?? defaultData["following"]).map((e) => TottoriUser(e.toString())).toList().cast<TottoriUser>(),
    );
  }

  Future<bool> get isValid async {
    List<String> validKeys = defaultData.keys.toList();
    Map<String, dynamic>? userData = await userDoc.get().then((value) {
      if (value.exists && value.data() != null) {
        return (value.data() as Map<String, dynamic>);
      }
      return null;
    });
    if (userData == null) return false;
    userData.forEach((key, value) {
      validKeys.remove(key);
    });
    return (validKeys.isEmpty);
  }

  Future<String?> get pfp async {
    final String pfpPath = 'user-profile-images/$uuid.jpg';
    final ref = FirebaseStorage.instance.ref().child(pfpPath);
    print("HELLO");
    print(await ref.getDownloadURL().then((value) => value).onError((error, stackTrace) {
      print("bad");
      return FirebaseStorage.instance.ref().child(defaultData["pfp"]).getDownloadURL();
    }));
    return await ref.getDownloadURL().then((value) => value).onError((error, stackTrace) {
      print("bad");
      return FirebaseStorage.instance.ref().child(defaultData["pfp"]).getDownloadURL();
    });
  }

  // Future<List<String>> get ownedTracks async {
  //   return await userDoc.get().then((value) {
  //     if (value.exists && value.data() != null) {
  //       return List<String>.from((value.data() as Map<String, dynamic>)["ownedTracks"] ?? []);
  //     } else {
  //       return [];
  //     }
  //   });
  // }

  Future<void> setUsername(String username) async {
    username = username.trim();
    if (!usernameRegExp.hasMatch(username)) {
      throw ("invalid-characters");
    } else if (username.length < 3) {
      throw ("username-too-short");
    } else if (username.length > 48) {
      throw ("username-too-long");
    } else {
      final document = FirebaseFirestore.instance.collection("usernames").doc(username.toLowerCase());
      await document.get().then((snapshot) async {
        final usernames = FirebaseFirestore.instance.collection("usernames");
        if (snapshot.exists && (snapshot.data() as Map<String, dynamic>)["owner"] != uuid) {
          throw ("username-taken");
        } else {
          await userDoc.get().then((value) {
            Map<String, dynamic> currentData = (value.data() as Map<String, dynamic>);
            usernames.doc(currentData["username"].toString().toLowerCase()).delete();
          });
          await usernames.doc(username.toLowerCase()).set({"owner": uuid});
          await userDoc.set({"username": username, "lowerCaseUsername": username.toLowerCase()}, SetOptions(merge: true));
        }
      });
    }
  }

  Future<void> setDisplayName(String displayName) async {
    displayName = displayName.trim();
    if (displayName.length < 3) {
      throw ("displayname-too-short");
    } else if (displayName.length > 48) {
      throw ("displayname-too-long");
    } else {
      await userDoc.set({"displayName": displayName, "lowerCaseDisplayName": displayName.toLowerCase()}, SetOptions(merge: true));
    }
  }

  Future<File> setPfp(File image, int size, int quality) async {
    final String pfpPath = 'user-profile-images/$uuid.jpg';
    final ref = FirebaseStorage.instance.ref().child(pfpPath);
    File uploadFile = await compressPfp(image, 256, 50);
    await ref.putFile(uploadFile);
    return uploadFile;
  }

  Future<File> setPfpFromUrl(String url, int size, int quality) async {
    Directory tempDir = await getTemporaryDirectory();
    return await setPfp(await http.get(Uri.parse(url)).then((response) => File("${tempDir.path}${const Uuid().v4()}.jpg").writeAsBytes(response.bodyBytes)), 256, 50);
  }

  Future<void> followUser(TottoriUser user) async {
    await userDoc.set({
      "following": FieldValue.arrayUnion([user.uuid])
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance.collection("users").doc(user.uuid).set({
      "followers": FieldValue.arrayUnion([uuid])
    }, SetOptions(merge: true));
  }

  Future<void> unfollowUser(TottoriUser user) async {
    await userDoc.set({
      "following": FieldValue.arrayRemove([user.uuid])
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance.collection("users").doc(user.uuid).set({
      "followers": FieldValue.arrayRemove([uuid])
    }, SetOptions(merge: true));
  }
}
