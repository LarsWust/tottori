import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tottori/classes/tottori_queue.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/helpers/account_helpers.dart';
import 'package:uuid/uuid.dart';
import '../components/expanded_svg.dart';

class TottoriTrack {
  final String uuid;
  late final DocumentReference<Map<String, dynamic>> trackDoc = FirebaseFirestore.instance.collection("tracks").doc(uuid);

  final Map<String, dynamic> trackDefaultData = {
    "likes": [].cast<TottoriUser>(),
    "title": "Tottori Track",
    "caption": "",
    "owner": TottoriUser(""),
    "images": [].cast<String>(),
    "queues": [].cast<TottoriQueue>(),
    "created": Timestamp.fromMillisecondsSinceEpoch(0),
    "edited": Timestamp.fromMillisecondsSinceEpoch(0),
    "tot": "tots/default.tot",
    "svg": null,
  };

  static final TottoriTrackData defaultData = TottoriTrackData(
    title: "Tottori Track",
    caption: "...",
    owner: TottoriUser(""),
    tot: "",
    svg: null,
    created: Timestamp.fromMillisecondsSinceEpoch(0),
    likes: [].cast<TottoriUser>(),
    images: [].cast<String>(),
    queues: [].cast<TottoriQueue>(),
    distance: 0,
  );

  TottoriTrack(this.uuid);

  Future<void> delete() async {
    TottoriTrackData snapshot = await data;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory("${appDocDir.path}/tot-svgs").createSync();
    File? svg;
    if (File("${appDocDir.path}/tot-svgs/${snapshot.tot}.svg").existsSync()) {
      await File("${appDocDir.path}/tot-svgs/${snapshot.tot}.svg").delete();
    }
    await FirebaseFirestore.instance.collection("users").doc(snapshot.owner.uuid).set(
      {
        "ownedTracks": FieldValue.arrayRemove([snapshot.tot])
      },
      SetOptions(merge: true),
    );
    // await FirebaseFirestore.instance.collection("users").where("likedTracks", arrayContains: uuid).get().then((value) {
    //   //TODO: I really hope this scales well :)
    //   //Actually im just gonna comment this out for now casue I dont think its needed
    //   for (var element in value.docs) {
    //     FirebaseFirestore.instance.collection("users").doc(element.id).set({
    //       "likedTracks": FieldValue.arrayRemove([uuid])
    //     });
    //   }
    // });
    await trackDoc.delete();
  }

  static Widget trackSvg(BuildContext context, {bool expandable = false, Color? color, File? svg, int? heroTag}) {
    SvgPicture svgPic = svg != null
        ? SvgPicture.file(
            svg,
            colorFilter: ColorFilter.mode(
              color ?? Theme.of(context).colorScheme.onBackground,
              BlendMode.srcIn,
            ),
          )
        : SvgPicture.asset(
            "lib/assets/default_track.svg",
            colorFilter: ColorFilter.mode(
              color ?? Theme.of(context).colorScheme.onBackground,
              BlendMode.srcIn,
            ),
          );
    return expandable
        ? Hero(
            tag: heroTag ?? svg.hashCode,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    transitionDuration: const Duration(milliseconds: 500),
                    reverseTransitionDuration: const Duration(milliseconds: 500),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    pageBuilder: (context, _, __) => ExpandedSvg(
                      svg: svgPic,
                      tag: heroTag ?? svg.hashCode,
                    ),
                  ),
                );
              },
              child: svgPic,
            ),
          )
        : svgPic;
  }

  Future<void> updateData({String title = "", String caption = "", List<File>? images}) async {
    title = title.trim();
    caption = caption.trim();
    if (images != null) {
      List<String> uuids = [];
      for (File image in images) {
        File compressedImage = await compressTrackImage(image, 2048, 80);
        String uuid = const Uuid().v4();
        uuids.add(uuid);
        FirebaseStorage.instance.ref("track-images").child("track-images/$uuid.jpg").putFile(compressedImage);
      }
      await trackDoc.set({"title": title, "lowerCaseTitle": title.toLowerCase(), "caption": caption, "edited": Timestamp.now(), "images": uuids}, SetOptions(merge: true));
    } else {
      await trackDoc.set({"title": title, "lowerCaseTitle": title.toLowerCase(), "caption": caption, "edited": Timestamp.now()}, SetOptions(merge: true));
    }
  }

  Future<TottoriTrackData> get data async {
    return await getDataInCase();
  }

  Future<TottoriTrackData> getDataInCase({TottoriUser? whoLiked}) async {
    Map<String, dynamic> trackData = await trackDoc.get().then((value) async {
      if (value.exists && value.data() != null) {
        return (value.data() as Map<String, dynamic>);
      } else {
        if (whoLiked != null) {
          await FirebaseFirestore.instance.collection("users").doc(whoLiked.uuid).set({
            "likedTracks": FieldValue.arrayRemove([uuid])
          }, SetOptions(merge: true));
        }
        return trackDefaultData;
      }
    });
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory("${appDocDir.path}/tot-svgs").createSync();
    File? svg;
    if (File("${appDocDir.path}/tot-svgs/${trackData["tot"]}.svg").existsSync()) {
      svg = File("${appDocDir.path}/tot-svgs/${trackData["tot"]}.svg");
    } else {
      List<int>? data = await FirebaseStorage.instance.ref().child("tot-svgs/${trackData["tot"]}.svg").getData().onError((error, stackTrace) {
        return null;
      });
      if (data != null) {
        svg = File("${appDocDir.path}/tot-svgs/${trackData["tot"]}.svg");
        await svg.writeAsBytes(data);
      }
    }
    return TottoriTrackData(
      title: trackData["title"] ?? "Tottori Track",
      distance: trackData["distance"] ?? 0,
      caption: trackData["caption"] ?? "",
      owner: TottoriUser(trackData["owner"] ?? ""),
      created: trackData["created"] ?? Timestamp.fromMillisecondsSinceEpoch(0),
      edited: trackData["edited"],
      likes: (trackData["likes"] ?? <String>[]).map((e) => TottoriUser(e)).toList().cast<TottoriUser>(),
      images: (trackData["images"] as List).map((e) => e as String).toList(),
      queues: (trackData["queues"] ?? <String>[]).map((e) => TottoriQueue(e)).toList().cast<TottoriQueue>(),
      tot: trackData["tot"] ?? "",
      svg: svg,
    );
  }

  Stream<TottoriTrackData> get dataStream {
    return trackDoc.snapshots().asyncMap((event) async {
      Map<String, dynamic> trackData;

      if (event.exists && event.data() != null) {
        trackData = (event.data() as Map<String, dynamic>);
      } else {
        trackData = trackDefaultData;
      }
      Directory appDocDir = await getApplicationDocumentsDirectory();
      Directory("${appDocDir.path}/tot-svgs").createSync();
      File? svg;
      if (File("${appDocDir.path}/tot-svgs/${trackData["tot"]}.svg").existsSync()) {
        svg = File("${appDocDir.path}/tot-svgs/${trackData["tot"]}.svg");
      } else {
        List<int>? data = await FirebaseStorage.instance.ref().child("tot-svgs/${trackData["tot"]}.svg").getData().onError((error, stackTrace) {
          return null;
        });
        if (data != null) {
          svg = File("${appDocDir.path}/tot-svgs/${trackData["tot"]}.svg");
          await svg.writeAsBytes(data);
        }
      }

      return TottoriTrackData(
        title: trackData["title"] ?? "Tottori Track",
        distance: trackData["distance"] ?? 0,
        caption: trackData["caption"] ?? "",
        owner: TottoriUser(trackData["owner"] ?? ""),
        created: trackData["created"] ?? Timestamp.fromMillisecondsSinceEpoch(0),
        edited: trackData["edited"],
        likes: (trackData["likes"] as List).map((e) => e as String).toList().map((e) => TottoriUser(e)).toList(),
        images: (trackData["images"] as List).map((e) => e as String).toList(),
        tot: trackData["tot"] ?? "",
        queues: (trackData["queues"] ?? <String>[]).map((e) => TottoriQueue(e)).toList().cast<TottoriQueue>(),
        svg: svg,
      );
    });
  }

  Future<String> setData(TottoriTrackData data) async {
    try {
      Map<String, dynamic> map = {
        "likes": data.likes.map((e) => e.uuid).toList(),
        "title": data.title,
        "caption": data.caption,
        "owner": data.owner.uuid,
        "images": data.images,
        "created": data.created,
        "edited": data.edited,
        "tot": data.tot,
        "lowerCaseTitle": data.title.toLowerCase(),
        "distance": data.distance,
      };
      await trackDoc.set(map, SetOptions(merge: true));
      Directory tempDir = await getTemporaryDirectory();
      File tempFile = File("${tempDir.path}/${data.tot}.tot");
      await FirebaseStorage.instance.ref().child("tots/${data.tot}.tot").putFile(tempFile);
      if (data.svg != null) {
        await FirebaseStorage.instance.ref().child("tot-svgs/${data.tot}.svg").putFile(data.svg!);
      }
      await data.owner.addTrack(data);
      return "";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> addImage(File image) async {
    File compressed = await compressTrackImage(image, 2048, 80);
    Reference imageRef = FirebaseStorage.instance.ref().child("track-images/${const Uuid().v4()}.jpg");
    await imageRef.putFile(compressed);
    return await imageRef.getDownloadURL();
  }

  Future<File?> getTot({String? name}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory("${appDocDir.path}/tots").createSync();
    File? totFile;
    if (File("${appDocDir.path}/tots/$uuid.tot").existsSync()) {
      totFile = File("${appDocDir.path}/tots/$uuid.tot");
    } else {
      List<int>? data = await FirebaseStorage.instance.ref().child("tots/$uuid.tot").getData().onError((error, stackTrace) {
        return null;
      });
      if (data != null) {
        totFile = File("${appDocDir.path}/tots/$uuid.tot");
        await totFile.writeAsBytes(data);
      }
    }
    if (totFile != null && name != null) {
      Directory tempDir = await getTemporaryDirectory();
      File renamedTot = File("${tempDir.path}/$name.tot");
      await renamedTot.writeAsBytes(await totFile.readAsBytes());
      return renamedTot;
    } else {
      return totFile;
    }
  }

  Future<void> addLike(TottoriUser user) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uuid).set({
      "likedTracks": FieldValue.arrayUnion([uuid])
    }, SetOptions(merge: true));
    await trackDoc.set({
      "likes": FieldValue.arrayUnion([user.uuid])
    }, SetOptions(merge: true));
  }

  Future<void> removeLike(TottoriUser user) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uuid).set({
      "likedTracks": FieldValue.arrayRemove([uuid])
    }, SetOptions(merge: true));
    await trackDoc.set({
      "likes": FieldValue.arrayRemove([user.uuid])
    }, SetOptions(merge: true));
  }
}
