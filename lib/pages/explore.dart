import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/components/track_feed_card.dart';
import 'package:tottori/main.dart';
import 'package:tottori/pages/home_page.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: TottoriUser(user!.uid).trackFeed(0, 30),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.value.isEmpty) {
              return SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Nothing's in your feed!"),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedPage = 2;
                          });
                        },
                        icon: const Icon(
                          Icons.search,
                        ),
                        label: const Text("Go find designers!"),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              var snapshotValue = snapshot.data!.value;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshotValue.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TrackFeedCard.fromExtendedData(
                      snapshotValue.entries.toList()[index],
                      // liked: snapshot.data!.key.likedTracks
                      //     .map(
                      //       (e) => e.uuid,
                      //     )
                      //     .contains(snapshotValue.entries.toList()[index].value.key.uuid),
                    ),
                  );
                },
              );
            }
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
