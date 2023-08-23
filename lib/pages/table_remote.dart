import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_queue.dart';
import 'package:tottori/components/queue_view.dart';
import 'package:tottori/main.dart';

class Remote extends StatefulWidget {
  const Remote({super.key});

  @override
  State<Remote> createState() => _RemoteState();
}

class _RemoteState extends State<Remote> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: FutureBuilder(
            future: currentUserData.ownedQueues.last.getData(),
            initialData: TottoriQueue.defaultData,
            builder: (context, snapshot) {
              return QueueView(
                queueData: snapshot.data!,
              );
            }));
  }
}
