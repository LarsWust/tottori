import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:tottori/classes/tottori_queue.dart';
import 'package:tottori/classes/tottori_table_data.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/main.dart';
import 'package:rxdart/rxdart.dart';

class TottoriTable {
  DiscoveredDevice? device;
  late String? name;
  StreamController<TottoriTableData> dataStreamController = BehaviorSubject<TottoriTableData>();
  StreamSubscription<TottoriTableData>? statusSubscription;
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);
  TottoriTableData? _latestData;
  QualifiedCharacteristic? wifiCredentialCharacteristic;
  QualifiedCharacteristic? statusCharacteristic;
  QualifiedCharacteristic? remoteCharacteristic;
  StreamSubscription<ConnectionStateUpdate>? currentConnectionStream;

  TottoriTable();

  fakeData() {
    name = "Fake Table";
    dataStreamController.add(TottoriTableData("1.1.1.1", false, null, null, null, null, null, false, false, null, 0, 1500, 1500, -1));
    isConnectedNotifier.value = true;
  }

  //TottoriTable._connect(this.device, this.wifiCredentialCharacteristic, this.statusCharacteristic, this.remoteCharacteristic, TottoriTableData startingData) {}

  Future<bool> togglePlay() {
    if (data == null) {
      print("returning false bc no data");

      return Future.value(false);
    }
    print(data!.isPlaying);
    if (data!.isPlaying == true) {
      return pause();
    } else {
      return play();
    }
  }

  disconnect() {
    isConnectedNotifier.value = false;
    statusSubscription?.cancel();
    currentConnectionStream?.cancel();
    wifiCredentialCharacteristic = null;
    statusCharacteristic = null;
    remoteCharacteristic = null;
    device = null;
    name = null;
  }

  Future<bool> pause() {
    return _update(isPlaying: false);
  }

  Future<bool> play() {
    return _update(isPlaying: true);
  }

  Future<bool> _update({bool? isPlaying, String? tQuid, int? queueIndex, bool? isLooping, bool? isShuffle, int? angSpeed, int? distSpeed, double? moveToX, double? moveToY}) {
    //  Format:
    //  isPlaying (0/1) 0x1D (T/Q)UID 0x1D queueIndex 0x1D isLooping (0/1) 0x1D isShuffle (0/1)
    return writeRemote("${isPlaying == true ? "1" : "0"}\x1D${tQuid ?? ""}\x1D$queueIndex\x1D${isLooping == true ? "1" : "0"}\x1D${isShuffle == true ? "1" : "0"}\x1D$angSpeed\x1D$distSpeed\x1D$moveToX\x1D$moveToY");
  }

  Future<bool> moveToPoint(double moveToX, moveToY) {
    return _update(moveToX: moveToX, moveToY: moveToY);
  }

  Future<bool> playTrack(TottoriTrack track) {
    return _update(isPlaying: true, tQuid: "T${track.uuid}");
  }

  Future<bool> playQueue(TottoriQueue queue) {
    return _update(isPlaying: true, tQuid: "Q${queue.uuid}");
  }

  Future<bool> playQueueAt(TottoriQueue queue, int index) {
    return _update(isPlaying: true, tQuid: "Q${queue.uuid}", queueIndex: index);
  }

  Future<bool> next() async {
    if (data?.currentQueue != null) {
      return _update(queueIndex: (data!.queueIndex! + 1) % data!.queueLength!);
    } else {
      return false;
    }
  }

  Future<bool> previous() async {
    if (data?.currentQueue != null) {
      return _update(queueIndex: (data!.queueIndex! - 1) % data!.queueLength!);
    } else {
      return false;
    }
  }

  Future<bool> setDistSpeed(int speed) {
    return _update(distSpeed: speed);
  }

  Future<bool> setAngSpeed(int speed) {
    return _update(angSpeed: speed);
  }

  TottoriTableData? get data {
    return _latestData;
  }

  Stream<TottoriTableData> get dataStream {
    return dataStreamController.stream;
  }

  Future<TottoriTable> connect(DiscoveredDevice device, StreamSubscription<ConnectionStateUpdate>? currentConnectionStream) async {
    disconnect();

    wifiCredentialCharacteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse("96209393-38a2-4740-9b09-467da594a13c"),
      characteristicId: Uuid.parse("42b7c22e-009c-43e6-a356-d7264f2a5ec5"),
      deviceId: device.id,
    );
    statusCharacteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse("96209393-38a2-4740-9b09-467da594a13c"),
      characteristicId: Uuid.parse("a9c0220b-1b06-48e7-a563-71731910a244"),
      deviceId: device.id,
    );
    remoteCharacteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse("96209393-38a2-4740-9b09-467da594a13c"),
      characteristicId: Uuid.parse("0f4e1e4c-0a50-4f6e-8569-1fef7bb657b4"),
      deviceId: device.id,
    );
    TottoriTableData startingData = await TottoriTableData.fromData(await flutterReactiveBle.readCharacteristic(statusCharacteristic!));
    name = device.name;
    this.device = device;
    _latestData = startingData;
    dataStreamController.add(startingData);
    if (statusSubscription != null) {
      await statusSubscription!.cancel();
      statusSubscription = null;
    }
    await statusSubscription?.cancel();
    statusSubscription = flutterReactiveBle.subscribeToCharacteristic(statusCharacteristic!).asyncMap((snapshot) async {
      TottoriTableData newData = await TottoriTableData.fromData(snapshot);
      _latestData = newData;
      return newData;
    }).listen(
      (newData) => dataStreamController.add(newData),
    );
    isConnectedNotifier.value = true;
    return this;
  }

  Future<bool> writeRemote(String data) {
    return writeCharacteristic(remoteCharacteristic, data);
  }

  Future<bool> writeCharacteristic(QualifiedCharacteristic? characteristic, String data) async {
    if (characteristic == null) {
      return false;
    } else {
      List<int> chars = ascii.encode(data);
      flutterReactiveBle.writeCharacteristicWithResponse(
        characteristic,
        value: chars,
      );
      return true;
    }
  }
}
