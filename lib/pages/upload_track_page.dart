import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_track_data.dart';
import 'package:tottori/classes/tottori_user.dart';
import 'package:tottori/main.dart';
import 'package:uuid/uuid.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ValueNotifier<Map<TottoriTrackData, String?>> uploadTracks = ValueNotifier({});
  ItemScrollController itemScrollController = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder(
            valueListenable: uploadTracks,
            builder: (context, value, child) {
              bool enabled = true;
              int c = 0;
              for (String? note in uploadTracks.value.values) {
                if (note == "Uploading") {
                  enabled = false;
                }
                if (note != null) {
                  c++;
                }
              }
              if (c == uploadTracks.value.length) {
                enabled = false;
              }

              return Column(children: [
                TextButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      allowMultiple: true,
                      type: FileType.custom,
                      allowedExtensions: ['gcode', 'svg', 'gcode.txt', 'tot'],
                    );
                    if (result != null) {
                      Directory tempDir = await getTemporaryDirectory();
                      for (PlatformFile file in result.files) {
                        if (file.path != null) {
                          String uuid = const Uuid().v4();
                          File tempFile = File("${tempDir.path}/$uuid.tot");
                          File svgFile = File("${tempDir.path}/$uuid.svg");
                          uploadTracks.value.addAll({
                            TottoriTrackData(
                              title: "Loading",
                              caption: "Loading",
                              owner: TottoriUser(""),
                              tot: "",
                              svg: null,
                              distance: 0,
                              created: Timestamp.now(),
                              likes: [],
                              images: [],
                              queues: [],
                            ): "Loading"
                          });
                          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                          uploadTracks.notifyListeners();
                          if (file.path!.endsWith(".gcode.txt") || file.path!.endsWith(".gcode") || (file.path!.contains(".gcode") && file.path!.endsWith(".txt"))) {
                            bool? rectangularMachine;
                            double? minX;
                            double? maxX;
                            double? minY;
                            double? maxY;
                            double? rangeY;
                            double? rangeX;
                            double? sX;
                            double? sY;
                            double? rX;
                            double? rY;
                            double distance = 0;
                            double? lastX;
                            double? lastY;
                            String totText = "";
                            String svgStart = """<svg version="1.1"
         width="1" height="1"
         xmlns="http://www.w3.org/2000/svg">
         <circle cx=".5" cy=".5" r=".4975" stroke-width=".005" fill="none" stroke="red"/>
        <polyline points=\"""";
                            String svgEnd = """"
        style="fill:none;stroke:black;stroke-width:.0025"/>
          </svg>""";
                            await File(file.path!).openRead().map(utf8.decode).transform(const LineSplitter()).forEach((line) {
                              line = line.trim();
                              // print(line);
                              if (line.startsWith(";")) {
                                if (rectangularMachine == null) {
                                  if (line.contains("Machine type: ")) {
                                    rectangularMachine = line.contains("Rectangular");
                                  }
                                } else if (rectangularMachine == true) {
                                  if (line.contains("Min X (mm): ")) {
                                    minX = double.parse(line.split(" ").last.trim());
                                  } else if (line.contains("Min Y (mm): ")) {
                                    minY = double.parse(line.split(" ").last.trim());
                                  } else if (line.contains("Max X (mm): ")) {
                                    maxX = double.parse(line.split(" ").last.trim());
                                  } else if (line.contains("Max Y (mm): ")) {
                                    maxY = double.parse(line.split(" ").last.trim());
                                  } else if (minX != null && minY != null && maxX != null && maxY != null) {
                                    rangeX = maxX! - minX!;
                                    rangeY = maxY! - minY!;
                                    double V = atan2(rangeY!, rangeX!);
                                    sX = ((1 + cos(pi - V)) / 2);
                                    sY = ((1 + sin(2 * pi - V)) / 2);
                                    rX = (((1 + cos(V)) / 2) - ((1 + cos(pi - V)) / 2));
                                    rY = (((1 + sin(V)) / 2) - ((1 + sin(2 * pi - V)) / 2));
                                  }
                                } else {
                                  if (line.contains("Max radius (mm): ")) {
                                    double radius = 2 * double.parse(line.split(" ").last.trim());
                                    minX = 0;
                                    minY = 0;
                                    maxX = radius;
                                    maxY = radius;
                                    rangeX = maxX! - minX!;
                                    rangeY = maxY! - minY!;
                                    print("$minX,$minY,$maxX,$maxY");
                                  }
                                }
                              }
                              if (line.startsWith("G")) {
                                List<String> parts = line.split(" ");
                                double? X = double.tryParse(parts[1].replaceAll("X", "").replaceAll(" ", ""));
                                double? Y = double.tryParse(parts[2].replaceAll("Y", "").replaceAll(" ", ""));

                                if (X != null && Y != null) {
                                  if (!rectangularMachine!) {
                                    X = minX! / (maxX!) + (X / (rangeX!));
                                    Y = -1 * (minY! / (maxY!) + (Y / (rangeY!))) + 1;
                                    lastX ??= X;
                                    lastY ??= Y;
                                    distance += sqrt(pow((X - lastX!), 2) + pow((Y - lastY!), 2));
                                    lastX = X;
                                    lastY = Y;
                                    totText += ("M$X $Y\n");
                                    svgStart += "$X $Y,";
                                  } else {
                                    X = sX! + (X - minX!) / rangeX! * rX!;
                                    Y = -1 * (sY! + (Y - minY!) / rangeY! * rY!) + 1;
                                    lastX ??= X;
                                    lastY ??= Y;
                                    distance += sqrt(pow((X - lastX!), 2) + pow((Y - lastY!), 2));
                                    lastX = X;
                                    lastY = Y;
                                    totText += ("M$X $Y\n");
                                    svgStart += "$X $Y,";
                                  }
                                }
                              }
                            });
                            svgStart = svgStart.substring(0, svgStart.length - 1) + svgEnd;
                            //print(svgStart);
                            svgFile.writeAsStringSync(svgStart.trim());
                            tempFile.writeAsStringSync(totText.trim());
                            TottoriTrackData trackData = TottoriTrackData(
                              distance: distance,
                              title: file.name.split(".").first,
                              caption: "",
                              owner: TottoriUser(user!.uid),
                              tot: uuid,
                              svg: svgFile,
                              created: Timestamp.now(),
                              likes: [],
                              images: [],
                              queues: [],
                            );
                            uploadTracks.value.removeWhere(
                              (key, value) => key.title == "Loading" && key.owner.uuid == "",
                            );
                            uploadTracks.value = uploadTracks.value..addAll({trackData: null});
                            // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                            uploadTracks.notifyListeners();
                            // await FirebaseStorage.instance.ref().child("tots/$uuid.tot").putFile(tempFile);
                          } else if (file.path!.endsWith(".tot")) {
                            String svgStart = """<svg version="1.1"
         width="1" height="1"
         xmlns="http://www.w3.org/2000/svg">
         <circle cx=".5" cy=".5" r=".4975" stroke-width=".005" fill="none" stroke="red"/>
        <polyline points=\"""";
                            String svgEnd = """"
        style="fill:none;stroke:black;stroke-width:.0025"/>
          </svg>""";
                            double distance = 0;
                            double? lastX;
                            double? lastY;
                            await File(file.path!).openRead().map(utf8.decode).transform(const LineSplitter()).forEach((line) {
                              line = line.trim();
                              if (line.startsWith("M")) {
                                List<String> parts = line.split(" ");
                                double? X = double.tryParse(parts[0].replaceAll("M", "").replaceAll(" ", ""));
                                double? Y = double.tryParse(parts[1].replaceAll(" ", ""));
                                if (X != null && Y != null) {
                                  svgStart += "$X $Y,";
                                  lastX ??= X;
                                  lastY ??= Y;

                                  distance += sqrt(pow((X - lastX!), 2) + pow((Y - lastY!), 2));
                                  lastX = X;
                                  lastY = Y;
                                }
                              }
                            });
                            svgStart = svgStart.substring(0, svgStart.length - 1) + svgEnd;
                            //print(svgStart);
                            tempFile.writeAsStringSync(await File(file.path!).readAsString());

                            svgFile.writeAsStringSync(svgStart.trim());

                            TottoriTrackData trackData = TottoriTrackData(
                              title: file.name.split(".").first,
                              caption: "",
                              owner: TottoriUser(user!.uid),
                              tot: uuid,
                              svg: svgFile,
                              created: Timestamp.now(),
                              likes: [],
                              images: [],
                              distance: distance,
                              queues: [],
                            );
                            uploadTracks.value.removeWhere(
                              (key, value) => key.title == "Loading" && key.owner.uuid == "",
                            );
                            uploadTracks.value = uploadTracks.value..addAll({trackData: null});
                            // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                            uploadTracks.notifyListeners();
                          }
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Select Tracks"),
                ),
                Expanded(
                  child: Builder(builder: (context) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ScrollablePositionedList.separated(
                          itemScrollController: itemScrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            TextEditingController titleController = TextEditingController(text: value.keys.toList()[index].title);
                            TextEditingController captionController = TextEditingController(text: value.keys.toList()[index].caption);
                            FocusNode focusNode = FocusNode();
                            String? note = value.values.toList()[index];
                            return Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: value.keys.toList()[index].svgPicture(context, expandable: true),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              value.keys.toList()[index].title,
                                              maxLines: null,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                        ],
                                      ),
                                      Builder(builder: (context) {
                                        if (note == null) {
                                          return Text(
                                            "${value.keys.toList()[index].svg?.lengthSync().readableFileSize() ?? "--"} • ${((value.keys.toList()[index].distance * 100).round()) / 100}",
                                            style: Theme.of(context).textTheme.labelLarge,
                                          );
                                        } else if (note == "Success!") {
                                          return Text(
                                            note,
                                            style: Theme.of(context).textTheme.labelLarge!.copyWith(color: const Color.fromARGB(255, 62, 147, 65)),
                                          );
                                        } else if (note == "Uploading" || note == "Loading") {
                                          return Row(
                                            children: [
                                              SizedBox(
                                                width: Theme.of(context).textTheme.labelLarge!.fontSize,
                                                height: Theme.of(context).textTheme.labelLarge!.fontSize,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Theme.of(context).textTheme.labelLarge!.color,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                note,
                                                style: Theme.of(context).textTheme.labelLarge,
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Text(
                                            note,
                                            style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.error),
                                          );
                                        }
                                      }),
                                    ],
                                  ),
                                ),
                                (note != "Success!" || note != "Uploading")
                                    ? IconButton(
                                        onPressed: () async {
                                          Navigator.of(context).push(PageRouteBuilder(
                                              opaque: false,
                                              barrierDismissible: true,
                                              transitionDuration: const Duration(milliseconds: 500),
                                              reverseTransitionDuration: const Duration(milliseconds: 500),
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                              pageBuilder: (BuildContext context, _, __) {
                                                FocusNode captionFocus = FocusNode();
                                                FocusNode titleFocus = FocusNode();
                                                return BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                  child: Dialog(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(24.0),
                                                      child: ListView(
                                                        padding: EdgeInsets.zero,
                                                        shrinkWrap: true,
                                                        children: [
                                                          Hero(
                                                            tag: value.keys.toList()[index].svg.hashCode.toString(),
                                                            child: Expanded(
                                                              child: AspectRatio(
                                                                aspectRatio: 1,
                                                                child: value.keys.toList()[index].svgPicture(context),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          TextField(
                                                            controller: titleController,
                                                            style: Theme.of(context).textTheme.titleLarge,
                                                            focusNode: titleFocus,
                                                            maxLength: 64,
                                                            onTapOutside: (event) {
                                                              titleFocus.unfocus();
                                                            },
                                                            onEditingComplete: () {
                                                              titleFocus.nextFocus();
                                                            },
                                                            onChanged: (e) {
                                                              value.keys.toList()[index].title = e.trim();
                                                            },
                                                            textInputAction: TextInputAction.next,
                                                            decoration: InputDecoration(
                                                              hintText: "Track title",
                                                              counterText: "",
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
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: TextField(
                                                              focusNode: captionFocus,
                                                              controller: captionController,
                                                              maxLength: 1024,
                                                              style: Theme.of(context).textTheme.bodyMedium,
                                                              maxLines: null,
                                                              onTapOutside: (event) {
                                                                captionFocus.unfocus();
                                                              },
                                                              onChanged: (e) {
                                                                value.keys.toList()[index].caption = e.trim();
                                                              },
                                                              decoration: InputDecoration(
                                                                counterText: "",
                                                                hintText: "Give me a short caption!",
                                                                focusedBorder: const OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                    color: Color(0xfffaa700),
                                                                    width: 3,
                                                                  ),
                                                                  borderRadius: BorderRadius.vertical(
                                                                    bottom: Radius.circular(10),
                                                                  ),
                                                                ),
                                                                enabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                    color: Theme.of(context).colorScheme.outline,
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius: const BorderRadius.vertical(
                                                                    bottom: Radius.circular(10),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text("Confirm"),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }));
                                        },
                                        icon: const Icon(Icons.edit),
                                        color: Theme.of(context).colorScheme.outlineVariant,
                                      )
                                    : const SizedBox.shrink(),
                                (note != "Success!" || note != "Uploading")
                                    ? IconButton(
                                        onPressed: () {
                                          uploadTracks.value.remove(value.keys.toList()[index]);
                                          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                                          uploadTracks.notifyListeners();
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: value.length,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextButton.icon(
                  onPressed: enabled
                      ? () async {
                          for (MapEntry<TottoriTrackData, String?> element in uploadTracks.value.entries) {
                            TottoriTrack track = TottoriTrack(element.key.tot);
                            if (uploadTracks.value[element.key] == null) {
                              setState(() {
                                uploadTracks.value[element.key] = "Uploading";
                              });
                              track.setData(element.key).then((result) => setState(() {
                                    if (result == "") {
                                      uploadTracks.value[element.key] = "Success!";
                                      HapticFeedback.lightImpact();
                                    } else {
                                      uploadTracks.value[element.key] = result;
                                      HapticFeedback.heavyImpact();
                                      Future.delayed(const Duration(milliseconds: 250), () => HapticFeedback.heavyImpact());
                                    }
                                  }));
                            }
                          }
                        }
                      : null,
                  icon: Icon(Icons.upload, color: enabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
                  label: Text(
                    "Upload",
                    style: enabled ? Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.primary) : Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ]);
            }),
      ),
    );
  }
}

extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (this <= 0) return "0";
    final units = ["B", "kB", "MB", "GB", "TB"];
    int digitGroups = (log(this) / log(base)).round();
    return "${NumberFormat("#,##0.#").format(this / pow(base, digitGroups))} ${units[digitGroups]}";
  }
}
