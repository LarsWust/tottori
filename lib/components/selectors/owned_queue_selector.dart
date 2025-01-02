import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:tottori/classes/tottori_queue_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/components/box_button.dart';
import 'package:tottori/components/box_button_type.dart';
import 'package:tottori/main.dart';

class OwnedQueueSelector extends StatefulWidget {
  const OwnedQueueSelector({
    super.key,
    required this.searchController,
    required this.selectedNotifier,
    required this.searchFocus,
  });

  final TextEditingController searchController;
  final ValueNotifier<List<TottoriQueueData>> selectedNotifier;
  final FocusNode searchFocus;

  @override
  State<OwnedQueueSelector> createState() => _OwnedQueueSelectorState();
}

class _OwnedQueueSelectorState extends State<OwnedQueueSelector> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75,
      child: Builder(builder: (context) {
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

                                for (TottoriQueueData selectQueueData in currentUserOwnedQueues ?? []) {
                                  widgets.add(
                                    Builder(
                                      builder: (context) {
                                        if (widget.searchController.text == "" || (selectQueueData.title.toLowerCase().contains(widget.searchController.text) ?? false)) {
                                          return Card(
                                            color: Theme.of(context).secondaryHeaderColor,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 50,
                                                    height: 50,
                                                    child: selectQueueData.getCoverImage(
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
                                                          selectQueueData.title,
                                                          style: Theme.of(context).textTheme.titleSmall,
                                                        ),
                                                        Text(
                                                          "@${currentUserData.username} • ${selectQueueData.readableDistance}",
                                                          style: Theme.of(context).textTheme.labelSmall,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  ValueListenableBuilder(
                                                    valueListenable: widget.selectedNotifier,
                                                    builder: (context, selected, child) {
                                                      bool isSelected = selected
                                                          .map(
                                                            (e) => (e.runtimeType == TottoriQueueData) ? (e).uid : null,
                                                          )
                                                          .contains(selectQueueData.uid);
                                                      return IntrinsicHeight(
                                                        child: BoxButton(
                                                          type: (isSelected == true) ? BoxButtonType.positive : BoxButtonType.normal,
                                                          icon: (isSelected == true) ? Icons.check : Icons.add,
                                                          onTap: () {
                                                            if (selectQueueData != null) {
                                                              (isSelected == true)
                                                                  ? widget.selectedNotifier.value.removeWhere((element) => (element.runtimeType == TottoriQueueData) ? (element).uid == selectQueueData.uid : false)
                                                                  : widget.selectedNotifier.value.add(selectQueueData);
                                                            }
                                                            // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                                            widget.selectedNotifier.notifyListeners();
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
                    widget.searchFocus.unfocus();
                  },
                  onTapOutside: (event) {
                    widget.searchFocus.unfocus();
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  controller: widget.searchController,
                  textInputAction: TextInputAction.search,
                  focusNode: widget.searchFocus,
                  decoration: InputDecoration(
                    suffixIcon: widget.searchController.text != ""
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                widget.searchController.clear();
                                widget.searchFocus.unfocus();
                              });
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
  }
}
