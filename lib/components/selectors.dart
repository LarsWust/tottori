import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_queue.dart';
import 'package:tottori/classes/tottori_queue_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/classes/tottori_user_data.dart';
import 'package:tottori/components/box_button.dart';
import 'package:tottori/components/box_button_type.dart';
import 'package:tottori/main.dart';

Future<List<TottoriQueueData>> selectAddingQueues(BuildContext context) async {
  ValueNotifier<List<TottoriQueueData>> selectedNotifier = ValueNotifier([]);
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.75,
        child: StreamBuilder<TottoriUserData>(
            stream: currentUserDataStream,
            initialData: currentUserData,
            builder: (context, userData) {
              Widget selectQueueView = Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ExpandableNotifier(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Card(
                                child: Flexible(
                                  child: Builder(
                                    builder: (context) {
                                      List<Widget> widgets = [];
                                      if (userData.data == null) {
                                        return Card(
                                          color: Theme.of(context).secondaryHeaderColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(children: const [
                                              CircularProgressIndicator(),
                                              SizedBox(
                                                width: 16,
                                              ),
                                              Text("Fetching queues"),
                                            ]),
                                          ),
                                        );
                                      }
                                      for (TottoriQueue queue in userData.data?.ownedQueues ?? []) {
                                        widgets.add(
                                          FutureBuilder(
                                            future: queue.getData(searchDepth: 1),
                                            initialData: TottoriQueue.defaultData,
                                            builder: (context, selectQueueData) {
                                              if (searchController.text == "" || (selectQueueData.data?.title.toLowerCase().contains(searchController.text) ?? false)) {
                                                return Card(
                                                  color: Theme.of(context).secondaryHeaderColor,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 50,
                                                          height: 50,
                                                          child: selectQueueData.data?.getCoverImage(
                                                            context,
                                                            expandable: true,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                // maxLines: 1,
                                                                // softWrap: false,
                                                                // overflow: TextOverflow.fade,
                                                                selectQueueData.connectionState == ConnectionState.done ? selectQueueData.data?.title ?? "n" : "Loading",
                                                                style: Theme.of(context).textTheme.titleSmall,
                                                              ),
                                                              FutureBuilder(
                                                                  future: selectQueueData.data?.owner.data,
                                                                  initialData: TottoriUser.defaultData,
                                                                  builder: (context, ownerData) {
                                                                    return Text(
                                                                      "@${ownerData.data?.username} • ${selectQueueData.data?.readableDistance}",
                                                                      style: Theme.of(context).textTheme.labelSmall,
                                                                    );
                                                                  }),
                                                            ],
                                                          ),
                                                        ),
                                                        ValueListenableBuilder(
                                                          valueListenable: selectedNotifier,
                                                          builder: (context, selected, child) {
                                                            bool isSelected = selected
                                                                .map(
                                                                  (e) => (e.runtimeType == TottoriQueueData) ? (e).uid : null,
                                                                )
                                                                .contains(selectQueueData.data?.uid);
                                                            return IntrinsicHeight(
                                                              child: BoxButton(
                                                                type: (isSelected == true) ? BoxButtonType.positive : BoxButtonType.normal,
                                                                icon: (isSelected == true) ? Icons.check : Icons.add,
                                                                onTap: () {
                                                                  if (selectQueueData.data != null) {
                                                                    (isSelected == true)
                                                                        ? selectedNotifier.value.removeWhere((element) => (element.runtimeType == TottoriQueueData) ? (element).uid == selectQueueData.data?.uid : false)
                                                                        : selectedNotifier.value.add(selectQueueData.data!);
                                                                  }
                                                                  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                                                  selectedNotifier.notifyListeners();
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            },
                                          ),
                                        );
                                      }

                                      return Column(
                                        children: widgets,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
              return Container(
                //height: 1500,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FractionallySizedBox(
                        widthFactor: 0.3,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outline,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Select Queues",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: TextField(
                        onEditingComplete: () {
                          searchFocus.unfocus();
                        },
                        onTapOutside: (event) {
                          searchFocus.unfocus();
                        },
                        controller: searchController,
                        textInputAction: TextInputAction.search,
                        focusNode: searchFocus,
                        decoration: InputDecoration(
                          suffixIcon: searchController.text != ""
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    searchFocus.unfocus();
                                  },
                                )
                              : const SizedBox.shrink(),
                          prefixIcon: const Icon(Icons.search),
                          hintText: "Search",
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.all(8),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 10,
                              color: Colors.transparent,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                16,
                              ),
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 10,
                              color: Colors.transparent,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: selectQueueView),
                  ],
                ),
              );
            }),
      );
    },
  );

  return selectedNotifier.value;
}
