import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/classes/tottori_user_data.dart';
import 'package:tottori/components/profile_card.dart';

class Profile extends StatefulWidget {
  final String uuid;
  final bool appbar;
  final TottoriUserData? data;
  const Profile({super.key, required this.uuid, this.appbar = false, this.data});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    if (widget.appbar) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ProfileCard(
                  TottoriUser(widget.uuid),
                  data: widget.data,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ProfileCard(TottoriUser(widget.uuid)),
              ),
            ],
          ),
        ),
      );
    }
  }
}
