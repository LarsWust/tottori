import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/components/profile_picture.dart';
import 'package:tottori/helpers/search.dart';
import 'package:tottori/pages/profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 24, 48, 0),
            child: TextField(
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              controller: searchController,
              focusNode: searchFocus,
              onTapOutside: (event) {
                searchFocus.unfocus();
              },
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.surface,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xfffaa700),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  hintText: "Search users"),
              autocorrect: false,
              style: const TextStyle(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: StreamBuilder(
                stream: search(searchController.text),
                /* (searchController.text != "")
                    ? FirebaseFirestore.instance
                        .collection("users")
                        .where("username", isGreaterThanOrEqualTo: searchController.text)
                        .where("username", isLessThanOrEqualTo: "${searchController.text}\uf8ff")
                       
                        .snapshots()
                    : FirebaseFirestore.instance.collection("users").snapshots(),*/
                builder: (BuildContext context, snapshot1) {
                  if (snapshot1.hasData) {
                    List<QuerySnapshot> querySnapshotData = snapshot1.data!.toList();

                    List<QueryDocumentSnapshot<Object?>> allDocuments = List.from(querySnapshotData[0].docs)..addAll(querySnapshotData[1].docs);

                    List<String> uniqueUsernames = [];
                    List<QueryDocumentSnapshot<Object?>> documents = [];
                    for (QueryDocumentSnapshot<Object?> document in allDocuments) {
                      String? username = (document.data() as Map<String, dynamic>)["username"];
                      if (username != null) {
                        if (!uniqueUsernames.contains(username)) {
                          uniqueUsernames.add(username);
                          documents.add(document);
                        }
                      }
                    }

                    if (documents.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return ListView(
                          shrinkWrap: true,
                          children: documents.map((DocumentSnapshot document) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).colorScheme.outline,
                                    width: 1,
                                  ),
                                  left: BorderSide(
                                    color: Theme.of(context).colorScheme.outline,
                                    width: 1,
                                  ),
                                  right: BorderSide(
                                    color: Theme.of(context).colorScheme.outline,
                                    width: 1,
                                  ),

                                  // borderRadius: BorderRadius.vertical(
                                  //   top: Radius.circular(10),
                                ),
                                // ),
                              ),
                              child: FutureBuilder(
                                  future: TottoriUser(document.id.toString().trim()).data,
                                  builder: (context, userSnapshot) {
                                    return IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          userSnapshot.hasData && userSnapshot.connectionState == ConnectionState.done
                                              ? ProfilePicture.image(
                                                  image: userSnapshot.data!.pfp,
                                                  expanable: true,
                                                )
                                              : ProfilePicture.blank(),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              Navigator.of(context).push(MaterialPageRoute(
                                                builder: (context) => Scaffold(
                                                  appBar: AppBar(title: const Text("Profile")),
                                                  body: Profile(
                                                    uuid: document.id,
                                                    data: userSnapshot.data,
                                                  ),
                                                ),
                                              ));
                                            },
                                            child: Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        document["displayName"],
                                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                      ),
                                                      Text(
                                                        " • ${(document.data() as Map<String, dynamic>)["ownedTracks"]?.length ?? 0} track${((document.data() as Map<String, dynamic>)["ownedTracks"]?.length ?? 0) != 1 ? "s" : ""}",
                                                        style: Theme.of(context).textTheme.labelSmall!.copyWith(),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    "@${document["username"]}",
                                                    style: Theme.of(context).textTheme.bodyMedium,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            );
                          }).toList()
                          // children: snapshot.data!.docs
                          //     .map((DocumentSnapshot document) {
                          //       Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                          //       return ListTile(
                          //         title: Text(data['username'] + "eee" ?? "e"),
                          //         subtitle: Text(data['displayName'] ?? "o"),
                          //       );
                          //     })
                          //     .toList()
                          //     .cast(),
                          );
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 50),
          //   child: FutureBuilder(
          //     future: search(searchController.text),
          //     builder: (context, snapshot) {
          //       return ListView.builder(
          //         itemCount: 10,
          //         shrinkWrap: true,
          //         itemBuilder: (context, index) {
          //           return Container(
          //             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          //             decoration: BoxDecoration(
          //               color: Theme.of(context).colorScheme.surfaceTint,
          //               border: Border(
          //                 bottom: BorderSide(
          //                   color: Theme.of(context).colorScheme.outline,
          //                   width: 1,
          //                 ),
          //                 left: BorderSide(
          //                   color: Theme.of(context).colorScheme.outline,
          //                   width: 1,
          //                 ),
          //                 right: BorderSide(
          //                   color: Theme.of(context).colorScheme.outline,
          //                   width: 1,
          //                 ),

          //                 // borderRadius: BorderRadius.vertical(
          //                 //   top: Radius.circular(10),
          //               ),
          //               // ),
          //             ),
          //             child: Text(searchController.text.substring(index)),
          //           );
          //         },
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
