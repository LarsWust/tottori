import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tottori/classes/tottori_queue.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/components/track_svg.dart';

class TottoriTrackData {
  String uid;
  String title;
  String caption;
  final TottoriUser owner;
  final String tot;
  final File? svg;
  double distance;
  Timestamp? edited;
  final Timestamp created;
  List<TottoriUser> likes;
  List<String> images;
  List<TottoriQueue> queues;

  TottoriTrackData({
    required this.uid,
    required this.title,
    required this.caption,
    required this.owner,
    required this.tot,
    required this.svg,
    required this.distance,
    required this.queues,
    this.edited,
    required this.created,
    required this.likes,
    required this.images,
  });

  static Widget defaultSvg(BuildContext context, {Color? color}) {
    return SvgPicture.asset(
      "lib/assets/default_track.svg",
      colorFilter: ColorFilter.mode(
        color ?? Theme.of(context).colorScheme.onBackground,
        BlendMode.srcIn,
      ),
    );
  }

  Widget svgPicture(BuildContext context, {bool expandable = false, Color? color}) {
    return TrackSvg(
      context,
      expandable: expandable,
      color: color,
      svg: svg,
    );
  }

  String get readableDistance {
    return (((distance * 100).round()) / 100).toString();
  }

  Future<File?> getTot({String? name}) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory("${appDocDir.path}/tots").createSync();
    File? totFile;
    if (File("${appDocDir.path}/tots/$tot.tot").existsSync()) {
      totFile = File("${appDocDir.path}/tots/$tot.tot");
    } else {
      List<int>? data = await FirebaseStorage.instance.ref().child("tots/$tot.tot").getData().onError((error, stackTrace) {
        return null;
      });
      if (data != null) {
        totFile = File("${appDocDir.path}/tots/$tot.tot");
        await totFile.writeAsBytes(data);
      }
    }
    if (totFile != null && name != null) {
      Directory tempDir = await getTemporaryDirectory();
      return totFile.copy("${tempDir.path}/$name.tot");
    } else {
      return totFile;
    }
  }
}
