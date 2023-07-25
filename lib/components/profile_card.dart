import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/classes/tottori_user_data.dart';
import 'package:tottori/components/profile_picture.dart';
import 'package:tottori/components/user_list.dart';
import 'package:tottori/main.dart';
import 'package:tottori/pages/profile_setup.dart';

class ProfileCard extends StatefulWidget {
  final TottoriUser user;
  final TottoriUserData? data;
  const ProfileCard(this.user, {super.key, this.data});

  @override
  State<ProfileCard> createState() => _ProfileCardState();

  Future<TottoriUserData> getData() async {
    if (data != null) {
      return data!;
    } else {
      return await user.data;
    }
  }
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
            future: widget.getData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: ProfilePicture.image(
                            image: snapshot.data!.pfp,
                            expanable: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data!.displayName,
                                style: Theme.of(context).textTheme.headlineSmall!,
                              ),
                              Text(
                                "@${snapshot.data!.username}",
                                style: Theme.of(context).textTheme.bodyMedium!,
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "${snapshot.data!.followers.length}",
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                      Text(
                                        "Followers",
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => TottoriUserList(users: snapshot.data!.following, title: "${snapshot.data!.displayName}'s Follows"),
                                      ));
                                    },
                                    child: Column(
                                      children: [
                                        Text(
                                          "${snapshot.data!.following.length}",
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        Text(
                                          "Following",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    widget.user.uuid == user!.uid
                        ? Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (context) => const ProfileSetupPage(),
                                  ));
                                },
                                label: const Text("Edit Profile"),
                                icon: const Icon(Icons.edit),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.background),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {},
                                label: const Text("Follow"),
                                icon: const Icon(Icons.add),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.background),
                                ),
                              ),
                            ],
                          )
                  ],
                );
              } else {
                return Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfilePicture.blank(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tottori User",
                                  style: Theme.of(context).textTheme.headlineSmall!,
                                ),
                                Text(
                                  "@tottori.user",
                                  style: Theme.of(context).textTheme.bodyMedium!,
                                ),
                                Divider(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "-",
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        Text(
                                          "Followers",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "-",
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        Text(
                                          "Following",
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            }),
      ),
    );
  }
}
