import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_queue.dart';
import 'package:tottori/classes/tottori_queue_data.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/classes/tottori_user_data.dart';
import 'package:tottori/components/box_button.dart';
import 'package:tottori/components/box_button_type.dart';
import 'package:tottori/components/selectors/owned_queue_selector.dart';
import 'package:tottori/components/selectors/owned_track_selector.dart';
import 'package:tottori/main.dart';

Future<List<TottoriQueueData>> selectAddingQueues(BuildContext context) async {
  ValueNotifier<List<TottoriQueueData>> selectedNotifier = ValueNotifier([]);
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return OwnedQueueSelector(searchController: searchController, selectedNotifier: selectedNotifier, searchFocus: searchFocus);
    },
  );

  return selectedNotifier.value;
}

Future<List<TottoriTrackData>> selectAddingTracks(BuildContext context) async {
  ValueNotifier<List<TottoriTrackData>> selectedNotifier = ValueNotifier([]);
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return OwnedTrackSelector(searchController: searchController, selectedNotifier: selectedNotifier, searchFocus: searchFocus);
    },
  );

  return selectedNotifier.value;
}
