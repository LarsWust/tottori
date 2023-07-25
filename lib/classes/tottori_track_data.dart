import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tottori/classes/tottori_user.dart';

class TottoriTrackData {
  final String title;
  final TottoriUser owner;
  final String tot;
  final Timestamp edited;
  final Timestamp created;
  final List<TottoriUser> likes;
  final List<String> images;

  TottoriTrackData({
    required this.title,
    required this.owner,
    required this.tot,
    required this.edited,
    required this.created,
    required this.likes,
    required this.images,
  });
}
