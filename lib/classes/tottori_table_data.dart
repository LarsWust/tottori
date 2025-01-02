import 'dart:convert';

import 'package:tottori/classes/tottori_queue.dart';
import 'package:tottori/classes/tottori_queue_data.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/classes/tottori_track_data.dart';

class TottoriTableData {
  String? ip;
  bool isPlaying;
  TottoriQueue? currentQueue;
  TottoriQueueData? currentQueueData;
  TottoriTrack? currentTrack;
  TottoriTrackData? currentTrackData;
  int? queueIndex;
  bool isLooping;
  bool isShuffle;
  int? queueLength;
  double trackProgress;
  int angSpeed;
  int distSpeed;
  double downloadProgress;

  TottoriTableData(this.ip, this.isPlaying, this.currentQueue, this.currentQueueData, this.currentTrack, this.currentTrackData, this.queueIndex, this.isLooping, this.isShuffle, this.queueLength, this.trackProgress, this.angSpeed,
      this.distSpeed, this.downloadProgress);

  static Future<TottoriTableData> fromData(List<int> data) async {
    String status = ascii.decode(data);
    // [47, 34, 34, 92, 92, 98, 8, 102, 12, 110, 10, 114, 13, 116, 9, 87, 105, 108, 100, 99, 97, 116, 95, 71, 117, 101, 115, 116, 115, 50, 57, 49, 48, 46, 52, 48, 46, 53, 56, 46, 49, 49, 50]

    // [1, 192.168.1.220, 0, Q,                                      , , 0, 0, 0, 0]
    // [1, 192.168.1.220, 1, T, Tdcf641e5-f71a-4774-8eae-25a977684848, , 0, 0, 0, 0]
    List<String> components = status.split('\x1D');
    String? ip = components[0] == "1" ? components[1] : null;
    bool isPlaying = components[2] == '1';
    bool isTrackSelected = components[3] == 'T';
    TottoriQueue? currentQueue;
    TottoriQueueData? currentQueueData;
    TottoriTrack? currentTrack;
    TottoriTrackData? currentTrackData;
    int? currentIndex;
    bool? isLooping;
    bool? isShuffle;
    int? queueLength;
    double trackProgress;
    int angSpeed;
    int distSpeed;
    double downloadProgress;
    if (isTrackSelected) {
      currentQueue = null;
      currentQueueData = null;
      currentTrack = components[4].isNotEmpty ? TottoriTrack(components[4]) : null;
      currentTrackData = await currentTrack?.data;
      currentIndex = null;
      queueLength = null;
    } else {
      currentQueue = components[5].isNotEmpty ? TottoriQueue(components[5]) : null;
      currentQueueData = await currentQueue?.getData();
      currentTrack = components[4].isNotEmpty ? TottoriTrack(components[4]) : null;
      currentTrackData = await currentTrack?.data;
      currentIndex = int.parse(components[6]);
      queueLength = int.parse(components[9]);
    }
    isLooping = components[7] == '1';
    isShuffle = components[8] == '1';
    trackProgress = double.parse(components[10]);
    angSpeed = int.parse(components[11]);
    distSpeed = int.parse(components[12]);
    downloadProgress = double.parse(components[13]);

    // IP, true, true,
    TottoriTableData newData = TottoriTableData(ip, isPlaying, currentQueue, currentQueueData, currentTrack, currentTrackData, currentIndex, isLooping, isShuffle, queueLength, trackProgress, angSpeed, distSpeed, downloadProgress);
    return newData;
  }

  @override
  String toString() {
    //This is lazy but it works lol
    return [
      "IP:",
      ip,
      "\nisPlaying:",
      isPlaying,
      "\ncurrentQueue:",
      currentQueue?.uuid,
      "\ncurrentQueueData:",
      currentQueueData,
      "\ncurrentTrack:",
      currentTrack?.uuid,
      "\ncurrentTrackData:",
      currentTrackData,
      "\nqueueIndex:",
      queueIndex,
      "\nisLooping:",
      isLooping,
      "\nisShuffle:",
      isShuffle,
      "\nqueueLength:",
      queueLength,
      "\ntrackProgress:",
      trackProgress,
      "\nangSpeed:",
      angSpeed,
      "\ndistSpeed:",
      distSpeed,
      "\ndownloadProgress:",
      downloadProgress
    ].toString();
  }
}
