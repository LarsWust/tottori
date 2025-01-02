import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tottori/main.dart';
import 'package:tottori/classes/tottori_user.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  Duration selectedDuration = const Duration(days: 31);
  TextEditingController dropdownController = TextEditingController(text: "Month");

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Top Tracks",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                DropdownMenu(
                  controller: dropdownController,
                  initialSelection: "Month",
                  width: 220,
                  leadingIcon: const Icon(Icons.calendar_month),
                  label: const Text('Top'),
                  inputDecorationTheme: InputDecorationTheme(
                    fillColor: Theme.of(context).colorScheme.surface,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  onSelected: (String? selected) {
                    Duration duration = const Duration(days: 31);
                    switch (selected) {
                      case "Today":
                        duration = const Duration(days: 1);
                        break;
                      case "Week":
                        duration = const Duration(days: 7);
                        break;
                      case "Month":
                        duration = const Duration(days: 31);
                        break;
                      case "All":
                        duration = const Duration(days: 10000);
                        break;
                    }
                    setState(() {
                      selectedDuration = duration;
                    });
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: "Today", label: "Today"),
                    DropdownMenuEntry(value: "Week", label: "Past Week"),
                    DropdownMenuEntry(value: "Month", label: "Past Month"),
                    DropdownMenuEntry(value: "All", label: "All Time"),
                  ],
                ),
              ],
            ),
            const Divider(),
            FutureBuilder(
              future: TottoriUser(user!.uid).trackFeed(selectedDuration),
              builder: (context, feed) {
                if (feed.connectionState == ConnectionState.done) {
                  if (feed.data!.isEmpty) {
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("It's empty in here..."),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                dropdownController.text = "All";
                                selectedDuration = const Duration(days: 10000);
                              });
                            },
                            child: const Text("Search for all time"),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                        itemCount: feed.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Container(
                                          width: constraints.maxWidth / 2,
                                          height: constraints.maxHeight / 2,
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
                                            color: Theme.of(context).cardColor,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 6.0, top: 2),
                                            child: Text(
                                              feed.data![index].likes.length.toString(),
                                              style: Theme.of(context).textTheme.labelSmall,
                                            ),
                                          ));
                                    },
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).cardColor,
                                    ),
                                    child: feed.data![index].svgPicture(context, expandable: true),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                } else {
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          "fetching tracks...",
                          style: Theme.of(context).textTheme.labelSmall,
                        )
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
