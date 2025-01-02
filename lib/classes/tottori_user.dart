import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tottori/classes/tottori_queue.dart';
import 'package:tottori/classes/tottori_queue_data.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/classes/tottori_user_data.dart';
import 'package:tottori/helpers/account_helpers.dart';
import 'package:tottori/main.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class TottoriUser {
  late final String uuid;
  late final DocumentReference<Map<String, dynamic>> userDoc = FirebaseFirestore.instance.collection("users").doc(uuid);
  static final RegExp usernameRegExp = RegExp("[0-9a-zA-Z\\._]");
  final Map<String, dynamic> userDefaultData = {
    "username": "tottori.user",
    "displayName": "Tottori User",
    "lowerCaseUsername": "tottori.user",
    "lowerCaseDisplayName": "tottori user",
    "pfp": Image.asset("lib/assets/default_picture.png"),
    "created": Timestamp.fromMillisecondsSinceEpoch(0),
    "followers": [].cast<String>(),
    "following": [].cast<String>(),
    "ownedTracks": [].cast<String>(),
    "likedTracks": [].cast<String>(),
    "ownedQueues": [].cast<String>(),
    "likedQueues": [].cast<String>(),
  };

  static final TottoriUserData defaultData = TottoriUserData(
    displayName: "Tottori User",
    username: "tottori.user",
    pfp: Image.asset("lib/assets/default_picture.png"),
    created: Timestamp.fromMillisecondsSinceEpoch(0),
    ownedTracks: [].cast<TottoriTrack>(),
    likedTracks: [].cast<TottoriTrack>(),
    followers: [].cast<TottoriUser>(),
    following: [].cast<TottoriUser>(),
    likedQueues: [].cast<TottoriQueue>(),
    ownedQueues: [].cast<TottoriQueue>(),
  );

  TottoriUser(String uuid) {
    this.uuid = uuid.trim();
  }

  Future<void> likeTrack(TottoriTrack track) async {
    await track.addLike(this);
  }

  Future<void> unlikeTrack(TottoriTrack track) async {
    await track.removeLike(this);
  }

  Future<List<TottoriTrackData>> trackFeed(Duration range) async {
    return await FirebaseFirestore.instance.collection('tracks').where('created', isGreaterThanOrEqualTo: DateTime.now().subtract(range)).limit(100).get().then((QuerySnapshot querySnapshot) async {
      return Future.wait(querySnapshot.docs.map((doc) async {
        return TottoriTrack(doc.id).data;
      })).then((value) => value..sort((a, b) => b.likes.length - a.likes.length)); // Sorting logic
    });
  }

  Stream<TottoriUserData> get dataStream {
    return userDoc.snapshots().asyncMap((event) async {
      Map<String, dynamic> userData = userDefaultData;
      if (event.exists && event.data() != null) {
        userData = event.data()!;
      }
      String pfpPath = 'user-profile-images/$uuid.jpg';
      final ref = FirebaseStorage.instance.ref().child(pfpPath);
      return TottoriUserData(
        displayName: userData["displayName"] ?? userDefaultData["displayName"],
        username: userData["username"] ?? userDefaultData["username"],
        pfp: await ref.getDownloadURL().then((uri) => Image.network(uri)).onError((error, stackTrace) => userDefaultData["pfp"]),
        created: userData["created"] ?? userDefaultData["created"],
        ownedTracks: (userData["ownedTracks"] ?? userDefaultData["ownedTracks"]).map((e) => TottoriTrack(e.toString())).toList().cast<TottoriTrack>(),
        likedTracks: (userData["likedTracks"] ?? userDefaultData["likedTracks"]).map((e) => TottoriTrack(e.toString())).toList().cast<TottoriTrack>(),
        likedQueues: (userData["likedQueues"] ?? userDefaultData["likedQueues"]).map((e) => TottoriQueue(e.toString())).toList().cast<TottoriQueue>(),
        ownedQueues: (userData["ownedQueues"] ?? userDefaultData["ownedQueues"]).map((e) => TottoriQueue(e.toString())).toList().cast<TottoriQueue>(),
        followers: (userData["followers"] ?? userDefaultData["followers"]).map((e) => TottoriUser(e.toString())).toList().cast<TottoriUser>(),
        following: (userData["following"] ?? userDefaultData["following"]).map((e) => TottoriUser(e.toString())).toList().cast<TottoriUser>(),
      );
    });
  }

  Future<TottoriUserData> get data async {
    if (uuid == user?.uid) {
      return currentUserData;
    }
    Map<String, dynamic> userData = await userDoc.get().then((value) {
      if (value.exists && value.data() != null) {
        return (value.data() as Map<String, dynamic>);
      } else {
        return userDefaultData;
      }
    });
    String pfpPath = 'user-profile-images/$uuid.jpg';
    final ref = FirebaseStorage.instance.ref().child(pfpPath);

    return TottoriUserData(
      displayName: userData["displayName"] ?? userDefaultData["displayName"],
      username: userData["username"] ?? userDefaultData["username"],
      pfp: await ref.getDownloadURL().then((uri) => Image.network(uri)).onError((error, stackTrace) => userDefaultData["pfp"]),
      created: userData["created"] ?? userDefaultData["created"],
      ownedTracks: (userData["ownedTracks"] ?? userDefaultData["ownedTracks"]).map((e) => TottoriTrack(e.toString())).toList().cast<TottoriTrack>(),
      likedTracks: (userData["likedTracks"] ?? userDefaultData["likedTracks"]).map((e) => TottoriTrack(e.toString())).toList().cast<TottoriTrack>(),
      likedQueues: (userData["likedQueues"] ?? userDefaultData["likedQueues"]).map((e) => TottoriQueue(e.toString())).toList().cast<TottoriQueue>(),
      ownedQueues: (userData["ownedQueues"] ?? userDefaultData["ownedQueues"]).map((e) => TottoriQueue(e.toString())).toList().cast<TottoriQueue>(),
      followers: (userData["followers"] ?? userDefaultData["followers"]).map((e) => TottoriUser(e.toString())).toList().cast<TottoriUser>(),
      following: (userData["following"] ?? userDefaultData["following"]).map((e) => TottoriUser(e.toString())).toList().cast<TottoriUser>(),
    );
  }

  Future<bool> get isValid async {
    List<String> validKeys = userDefaultData.keys.toList();
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

  Future<Image> get pfp async {
    final String pfpPath = 'user-profile-images/$uuid.jpg';
    final ref = FirebaseStorage.instance.ref().child(pfpPath);
    return await ref.getDownloadURL().then((value) => Image.network(value)).onError((error, stackTrace) {
      return Image.asset("lib/assets/default_picture.png");
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

  Future<void> setTimestamp(Timestamp timestamp) async {
    userDoc.set({"created": timestamp}, SetOptions(merge: true));
  }

  Future<void> initTimestamp() async {
    if (await userDoc.get().then((value) => !(value.data() as Map<String, dynamic>).containsKey("created"))) {
      setTimestamp(Timestamp.now());
    }
  }

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
    File uploadFile = await compressPfp(image, size, quality);
    await ref.putFile(uploadFile);
    return uploadFile;
  }

  Future<File> setPfpFromUrl(String url, int size, int quality) async {
    Directory tempDir = await getTemporaryDirectory();
    return await setPfp(await http.get(Uri.parse(url)).then((response) => File("${tempDir.path}${const Uuid().v4()}.jpg").writeAsBytes(response.bodyBytes)), 256, 80);
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

  Future<void> addTrack(TottoriTrackData trackData) async {
    await userDoc.set({
      "ownedTracks": FieldValue.arrayUnion([trackData.tot])
    }, SetOptions(merge: true));
  }

  Future<void> removeTrack(TottoriTrackData trackData) async {
    await userDoc.set({
      "ownedTracks": FieldValue.arrayRemove([trackData.tot])
    }, SetOptions(merge: true));
  }

  Future<void> addQueue(TottoriQueueData queueData) async {
    await userDoc.set({
      "ownedTracks": FieldValue.arrayRemove([queueData.uid])
    }, SetOptions(merge: true));
  }

  Future<void> removeQueue(TottoriQueueData queueData) async {
    await userDoc.set({
      "ownedTracks": FieldValue.arrayRemove([queueData.uid])
    }, SetOptions(merge: true));
  }
}
