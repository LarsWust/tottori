import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_user.dart';

class TottoriUserData {
  String displayName;
  String username;
  Image pfp;
  final Timestamp created;
  List<TottoriTrack> ownedTracks;
  List<TottoriUser> followers;
  List<TottoriUser> following;

  TottoriUserData({
    required this.displayName,
    required this.username,
    required this.pfp,
    required this.created,
    required this.ownedTracks,
    required this.followers,
    required this.following,
  });
}
