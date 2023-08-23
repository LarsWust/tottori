import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_queue.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/components/profile_picture.dart';

class TottoriQueueData {
  String title;
  String caption;
  String uid;
  int length;
  double distance;
  TottoriUser owner;
  Timestamp created;
  Timestamp? edited;
  List<dynamic> _children = [];
  List<TottoriUser> likes;
  List<TottoriQueue> dependants;
  File? cover;

  TottoriQueueData({
    required this.title,
    required this.caption,
    required this.owner,
    required this.length,
    required this.distance,
    required this.uid,
    required this.dependants,
    required this.created,
    required this.edited,
    required List<dynamic> children,
    required this.likes,
    required this.cover,
  }) {
    setChildren(children);
    //_children = children;
  }

  bool get isGenerated {
    return uid != "";
  }

  String get readableDistance {
    return (((distance * 100).round()) / 100).toString();
  }

  Future<void> createQueue() async {
    setChildren(_children);
    await TottoriQueue(uid).setData(this, merge: false);
    owner.addQueue(this);
  }

  void calculateDistLen() {
    List<double> newDist = [];
    List<int> newLen = [];
    for (var child in _children) {
      if (child.runtimeType == TottoriQueueData) {
        child = child as TottoriQueueData;
        newDist.add(child.distance);
        newLen.add(child.length);
        //TottoriQueue(child.uid).addDependant(this);
      } else if (child.runtimeType == TottoriTrackData) {
        child = child as TottoriTrackData;
        newDist.add(child.distance);
        newLen.add(1);
      }
    }
    distance = newDist.reduce((a, b) => a + b);
    length = newLen.reduce((a, b) => a + b);
  }

  Future<void> addChildren(List<dynamic> newChildren, {bool expanded = false}) async {}

  Future<void> removeChildren(List<dynamic> removedChildren, {bool expanded = false}) async {
    _children.removeWhere((element) {
      if (element.runtimeType == TottoriTrackData) {
        element = element as TottoriTrackData;
        List<String?> removedChildrenMap = removedChildren.toList().map((e) => (e.runtimeType == TottoriTrackData) ? (e as TottoriTrackData).tot : null).toList();
        return (removedChildrenMap.contains(element.tot));
      } else if (element.runtimeType == TottoriQueueData) {
        element = element as TottoriQueueData;
        List<String?> removedChildrenMap = removedChildren.toList().map((e) => (e.runtimeType == TottoriQueueData) ? (e as TottoriQueueData).uid : null).toList();
        return (removedChildrenMap.contains(element.uid));
      } else if (element.runtimeType == TottoriQueue) {
        element = element as TottoriQueue;
        List<String?> removedChildrenMap = removedChildren.toList().map((e) => (e.runtimeType == TottoriQueue) ? (e as TottoriQueue).uuid : null).toList();
        return (removedChildrenMap.contains(element.uuid));
      }
      return false;
    });
    return calculateDistLen();
  }

  Future<void> removeAt(int index, {bool expanded = false}) async {
    _children.removeAt(index);
    return calculateDistLen();
  }

  Future<void> setChildren(List<dynamic> newChildren, {bool expanded = false}) async {
    List<double> newDist = [];
    List<int> newLength = [];

    for (var oldChild in _children) {
      if (oldChild.runtimeType == TottoriQueueData) {
        oldChild = oldChild as TottoriQueueData;
        if (!newChildren.toList().map((e) => (e.runtimeType == TottoriQueueData) ? (e as TottoriQueueData).uid : null).contains(oldChild.uid)) {
          TottoriQueue(oldChild.uid).removeDependant(TottoriQueue((uid)));
        }
      }
    }

    for (var newChild in newChildren) {
      if (newChild.runtimeType == TottoriQueueData || newChild.runtimeType == TottoriTrackData) {
        newDist.add(newChild.distance);
      }
      if (newChild.runtimeType == TottoriQueueData) {
        newLength.add(newChild.length as int);
      }
      if (newChild.runtimeType == TottoriTrackData) {
        newLength.add(1);
      }
      if (newChild.runtimeType == TottoriQueueData) {
        newChild = newChild as TottoriQueueData;
        TottoriQueue(newChild.uid).addDependant(TottoriQueue((uid)));
      } else if (newChildren.runtimeType == TottoriTrackData) {
        newChild = newChild as TottoriTrackData;
      }
    }

    distance = newDist.reduce((a, b) => a + b);
    length = newLength.reduce((a, b) => a + b);
    _children = newChildren;
    expanded ? await expandChildren() : null;
  }

  List<dynamic> get getChildren {
    return _children;
  }

  Future<void> expandChildren({int depth = 10}) async {
    List<dynamic> expanded = [];
    if (depth > 0) {
      for (dynamic child in _children) {
        if (child.runtimeType == TottoriTrackData) {
          child = child as TottoriTrackData;
          expanded.add(child);
        } else if (child.runtimeType == TottoriQueueData) {
          child = child as TottoriQueueData;
          await child.expandChildren(depth: depth - 1);
          expanded.add(child);
        } else if (child.runtimeType == TottoriQueue) {
          child = child as TottoriQueue;
          expanded.add(await child.getData(searchDepth: depth - 1));
        }
      }
    }
    _children = expanded;
  }

  Widget getCoverImage(BuildContext context, {bool expandable = false, int? heroTag}) {
    if (cover?.path.split(".").last == "svg") {
      return TottoriTrack.trackSvg(context, svg: cover, expandable: expandable, heroTag: heroTag);
    } else if (cover?.path.split(".").last == "jpg") {
      return ProfilePicture.image(image: Image.file(cover!), expanable: expandable, heroTag: heroTag);
    } else {
      return TottoriTrack.trackSvg(context);
    }
  }
}
