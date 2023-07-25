import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/helpers/account_helpers.dart';
import 'package:uuid/uuid.dart';

class TottoriTrack {
  late final String uuid;
  late final DocumentReference<Map<String, dynamic>> trackDoc = FirebaseFirestore.instance.collection("tracks").doc(uuid);
  final Map<String, dynamic> defaultData = {
    "likes": [],
    "title": "Tottori Track",
    "owner": TottoriUser(""),
    "images": [],
    "created": Timestamp.fromMillisecondsSinceEpoch(0),
    "edited": Timestamp.fromMillisecondsSinceEpoch(0),
    "tot": "tracks/default.tot",
  };
  TottoriTrack(String uuid) {
    this.uuid = uuid.trim();
  }

  Future<TottoriTrackData> get data async {
    Map<String, dynamic> trackData = await trackDoc.get().then((value) {
      if (value.exists && value.data() != null) {
        return (value.data() as Map<String, dynamic>);
      } else {
        return defaultData;
      }
    });
    return TottoriTrackData(
      title: trackData["title"],
      owner: TottoriUser(trackData["owner"]),
      created: trackData["created"],
      edited: trackData["edited"],
      likes: (trackData["likes"] as List<String>).map((e) => TottoriUser(e)).toList(),
      images: trackData["images"],
      tot: trackData["tot"],
    );
  }

  Future<void> setData(TottoriTrackData data) async {
    Map<String, dynamic> map = {
      "likes": data.likes.map((e) => e.uuid) as List<String>,
      "title": data.title,
      "owner": data.owner,
      "images": data.images,
      "created": data.created,
      "edited": data.edited,
      "tot": data.tot,
    };
    await trackDoc.set(map, SetOptions(merge: true));
  }

  Future<String> addImage(File image) async {
    File compressed = await compressTrackImage(image, 2048, 80);
    Reference imageRef = FirebaseStorage.instance.ref().child("track-images/${const Uuid().v4()}.jpg");
    await imageRef.putFile(compressed);
    return await imageRef.getDownloadURL();
  }
}
