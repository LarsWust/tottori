import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tottori/classes/tottori_queue_data.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:uuid/uuid.dart';

class TottoriQueue {
  final String uuid;
  static int nestDepth = 10;
  late final DocumentReference<Map<String, dynamic>> queueDoc = FirebaseFirestore.instance.collection("queues").doc(uuid);

  static final TottoriQueueData defaultData = TottoriQueueData(
    title: "Tottori Queue",
    caption: "...",
    owner: TottoriUser(""),
    created: Timestamp.fromMillisecondsSinceEpoch(0),
    likes: [].cast<TottoriUser>(),
    cover: null,
    children: [],
    distance: 0,
    length: 0,
    edited: Timestamp.fromMillisecondsSinceEpoch(0),
    uid: "",
    dependants: [],
  );

  TottoriQueue(this.uuid);

  Future<void> addTrack(TottoriTrackData track) async {
    DocumentReference trackDoc = FirebaseFirestore.instance.collection("tracks").doc(track.tot);
    await trackDoc.set({
      "queues": FieldValue.arrayUnion([uuid])
    }, SetOptions(merge: true));
    await queueDoc.set({
      "children": FieldValue.arrayUnion(["T${track.tot}"]),
      "length": FieldValue.increment(1),
      "distance": FieldValue.increment(track.distance),
      "edited": Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> addQueue(TottoriQueueData queue) async {
    TottoriQueue(queue.uid).addDependant(this);

    await queueDoc.set({
      "children": FieldValue.arrayUnion(["Q${queue.uid}"]),
      "length": FieldValue.increment(queue.length),
      "distance": FieldValue.increment(queue.distance),
      "edited": Timestamp.now(),
    }, SetOptions(merge: true));
  }

  ///Set `searchDepth` to `1` if `TottoriTrackData.children` isn't needed
  Future<TottoriQueueData> getData({int? searchDepth}) async {
    searchDepth ??= nestDepth;
    if (searchDepth == 0) {
      return defaultData;
    }
    Map<String, dynamic>? queueData = await queueDoc.get().then((value) {
      if (value.exists && value.data() != null) {
        return (value.data() as Map<String, dynamic>);
      }
      return null;
    });
    if (queueData == null) {
      return defaultData;
    }

    List<dynamic> children = [];
    for (String child in queueData["children"]) {
      if (child.startsWith("T")) {
        children.add(await TottoriTrack(child.substring(1)).data);
      } else if (child.startsWith("Q")) {
        // ignore: use_build_context_synchronously
        if (searchDepth - 1 == 0) {
          children.add(TottoriQueue(child.substring(1)));
        } else {
          children.add(await TottoriQueue(child.substring(1)).getData(searchDepth: searchDepth - 1));
        }
      }
    }
    File? cover;

    String? path = queueData["coverPath"];
    if (path != null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      Directory("${appDocDir.path}/${path.split("/").first}").createSync();
      if (File("${appDocDir.path}/$path").existsSync()) {
        cover = File("${appDocDir.path}/$path");
      } else {
        List<int>? data = await FirebaseStorage.instance.ref().child(path).getData().onError((error, stackTrace) {
          return null;
        });
        if (data != null) {
          cover = File("${appDocDir.path}/$path");
          await cover.writeAsBytes(data);
        }
      }
    }

    return TottoriQueueData(
      caption: queueData["caption"] ?? defaultData.caption,
      title: queueData["title"] ?? defaultData.title,
      created: queueData["created"] ?? defaultData.created,
      length: queueData["length"] ?? defaultData.length,
      distance: queueData["distance"] ?? defaultData.distance,
      edited: queueData["edited"],
      children: children,
      cover: cover,
      likes: (queueData["likes"] ?? <String>[]).map((e) => TottoriUser(e)).toList().cast<TottoriUser>(),
      dependants: (queueData["dependants"] ?? <String>[]).map((e) => TottoriQueue(e)).toList().cast<TottoriQueue>(),
      owner: TottoriUser(queueData["owner"] ?? ""),
      uid: uuid,
    );
  }

  Future<void> setData(TottoriQueueData data, {bool merge = true}) async {
    List<String> children = [];
    for (var child in data.getChildren) {
      if (child.runtimeType == TottoriTrackData) {
        children.add("T${(child as TottoriTrackData).tot}");
      } else if (child.runtimeType == TottoriQueueData) {
        children.add("Q${(child as TottoriQueueData).uid}");
      }
    }

    Map<String, dynamic> setMap = {
      "caption": data.caption,
      "title": data.title,
      "created": data.created,
      "edited": data.edited,
      "children": children,
      "likes": data.likes.map((e) => e.uuid).cast<String>(),
      "owner": data.owner.uuid,
      "length": data.length,
      "distance": data.distance,
      "dependants": data.dependants.map((e) => e.uuid).cast<String>(),
    };
    if (data.cover?.path.split(".").last == "svg") {
      //return TottoriTrack.trackSvg(context, svg: cover);
      String fileName = const Uuid().v4();
      await FirebaseStorage.instance.ref().child("queue-svgs/$fileName.svg").putFile(data.cover!);
      setMap.addAll({"coverPath": "queue-svgs/$fileName"});
    } else if (data.cover?.path.split(".").last == "jpg") {
      //return Image.file(cover!);
      String fileName = const Uuid().v4();
      await FirebaseStorage.instance.ref().child("queue-images/$fileName.jpg").putFile(data.cover!);
      setMap.addAll({"coverPath": "queue-images/$fileName.jpg"});
    }

    await FirebaseFirestore.instance.collection("users").doc(data.owner.uuid).set({
      "ownedQueues": FieldValue.arrayUnion([data.uid])
    }, SetOptions(merge: true));
    await queueDoc.set(setMap, SetOptions(merge: merge));
  }

  Future<void> addDependant(TottoriQueue dependant) async {
    await queueDoc.set({
      "dependants": FieldValue.arrayUnion([dependant.uuid])
    }, SetOptions(merge: true));
  }

  Future<void> removeDependant(TottoriQueue dependant) async {
    await queueDoc.set({
      "dependants": FieldValue.arrayRemove([dependant.uuid])
    }, SetOptions(merge: true));
  }

  Future<void> removeFromDependency(TottoriQueueData dependency) async {
    await queueDoc.set({
      "children": FieldValue.arrayRemove(["Q${dependency.uid}"])
    }, SetOptions(merge: true));
  }

  Future<void> delete() async {
    TottoriQueueData data = await getData();
    for (TottoriQueue queue in data.dependants) {
      queue.removeFromDependency(data);
    }
    await data.owner.removeQueue(data);
    await queueDoc.delete();
  }
}
