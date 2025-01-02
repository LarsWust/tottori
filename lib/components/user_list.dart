import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/components/profile_picture.dart';
import 'package:tottori/pages/profile.dart';

class TottoriUserList extends StatefulWidget {
  final List<TottoriUser> users;
  final String title;
  const TottoriUserList({super.key, required this.users, required this.title});

  @override
  State<TottoriUserList> createState() => _TottoriUserListState();
}

class _TottoriUserListState extends State<TottoriUserList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
          child: ListView.builder(
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 80,
              child: Card(
                  child: FutureBuilder(
                      future: widget.users[index].data,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          //return Text(snapshot.data!.username);

                          return IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ProfilePicture.image(
                                    image: snapshot.data!.pfp,
                                    expanable: true,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                          appBar: AppBar(title: const Text("Profile")),
                                          body: Profile(
                                            uuid: widget.users[index].uuid,
                                            data: snapshot.data!,
                                          ),
                                        ),
                                      ),
                                    ),
                                    behavior: HitTestBehavior.translucent,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data!.displayName,
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        Text(
                                          "@${snapshot.data!.username}",
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ProfilePicture.blank(),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tottori User",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                      Text(
                                        "@tottori.user",
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      })),
            ),
          );
        },
      )),
    );
  }
}
