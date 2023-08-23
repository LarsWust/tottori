import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Stream<List<QuerySnapshot<Map<String, dynamic>>>> search(String input, {String? type}) {
  input = input.toLowerCase().trim();
  String inputUsername = input.replaceAll("@", "").replaceAll(" ", "");
  print(inputUsername);

  Stream<QuerySnapshot<Map<String, dynamic>>> usernameStream = (input != "")
      ? FirebaseFirestore.instance.collection("users").where("lowerCaseUsername", isGreaterThanOrEqualTo: input).where("lowerCaseUsername", isLessThanOrEqualTo: "$input\uf8ff").orderBy("lowerCaseUsername").limit(50).snapshots()
      : FirebaseFirestore.instance.collection("users").limit(50).snapshots();
  Stream<QuerySnapshot<Map<String, dynamic>>> displayNameStream = (input != "")
      ? FirebaseFirestore.instance
          .collection("users")
          .where("lowerCaseDisplayName", isGreaterThanOrEqualTo: inputUsername)
          .where("lowerCaseDisplayName", isLessThanOrEqualTo: "$inputUsername\uf8ff")
          .orderBy("lowerCaseDisplayName")
          .limit(50)
          .snapshots()
      : FirebaseFirestore.instance.collection("tracks").limit(50).snapshots();
  //TODO: Implement
  // Stream<QuerySnapshot<Map<String, dynamic>>> trackStream = (input != "")
  //     ? FirebaseFirestore.instance.collection("tracks").where("lowerCaseTitle", isGreaterThanOrEqualTo: inputUsername).where("lowerCaseTitle", isLessThanOrEqualTo: "$inputUsername\uf8ff").orderBy("lowerCaseTitle").limit(50).snapshots()
  //     : FirebaseFirestore.instance.collection("tracks").limit(50).snapshots();
  // Stream<QuerySnapshot<Map<String, dynamic>>> queueStream = (input != "")
  //     ? FirebaseFirestore.instance.collection("queues").where("lowerCaseTitle", isGreaterThanOrEqualTo: inputUsername).where("lowerCaseTitle", isLessThanOrEqualTo: "$inputUsername\uf8ff").orderBy("lowerCaseTitle").limit(50).snapshots()
  //     : FirebaseFirestore.instance.collection("queues").limit(50).snapshots();
  return StreamZip([
    displayNameStream,
    usernameStream,
  ]).asBroadcastStream();
}
