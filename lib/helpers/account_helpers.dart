import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tottori/main.dart';
import 'package:image/image.dart' as img;

Future<File> compressPfp(File image, int width, int quality) async {
  img.Image resized = img.copyResize(img.decodeImage(await image.readAsBytes())!, width: width, height: width);
  return await image.writeAsBytes(img.encodeJpg(resized, quality: quality));
}

Future<File> compressTrackImage(File image, int maxEdge, int quality) async {
  img.Image? decoded = img.decodeImage(await image.readAsBytes());
  bool widthLongest = decoded!.width > decoded.height;
  int longestSide = widthLongest ? decoded.width : decoded.height;
  if (longestSide > maxEdge) {
    img.Image resized;
    if (widthLongest) {
      resized = img.copyResize(img.decodeImage(await image.readAsBytes())!, width: maxEdge);
    } else {
      resized = img.copyResize(img.decodeImage(await image.readAsBytes())!, height: maxEdge);
    }
    return image.writeAsBytes(img.encodeJpg(resized, quality: quality));
  } else {
    return await image.writeAsBytes(img.encodeJpg(decoded, quality: quality));
  }
}

Future<File> setPfp(File image, int width, int quality) async {
  final String pfpPath = 'user-profile-images/${user?.uid}.jpg';
  final ref = FirebaseStorage.instance.ref().child(pfpPath);
  File uploadFile = await compressPfp(image, 256, 50);
  await ref.putFile(uploadFile);
  await user?.updatePhotoURL(await ref.getDownloadURL());
  return uploadFile;
}

void fixAccount() async {
  if (user != null) {
    DocumentReference doc = FirebaseFirestore.instance.collection("users").doc(user!.uid);
    final username = await doc.get().then((value) {
      if (value.exists && value.data() != null) {
        return (value.data() as Map<String, dynamic>)["username"] ?? user!.displayName;
      } else {
        return user!.displayName;
      }
    });
    await doc.set({
      "displayName": user!.displayName,
      "username": username,
    });
  }
}

Future<bool> isAccountValid() async {
  if (user != null) {
    DocumentReference doc = FirebaseFirestore.instance.collection("users").doc(user!.uid);
    if (await doc.get().then((value) {
      Map<String, dynamic> userData = (value.data() as Map<String, dynamic>);
      if (userData.containsKey("username") && userData.containsKey("displayName")) {
        if (userData["username"].toString().length >= 3 && userData["username"].toString().length <= 48) {
          if (userData["displayName"].toString().length >= 3 && userData["displayName"].toString().length <= 48) {
            return true;
          }
        }
      }
      return false;
    })) {}
  }
  return false;
}
