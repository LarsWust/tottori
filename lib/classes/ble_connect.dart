import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:tottori/main.dart';

class BLEConnect {
  static StreamSubscription? scanSubscription;
  static ValueNotifier<List<DiscoveredDevice>> deviceList = ValueNotifier([]);
  static ValueNotifier<DiscoveredDevice?> connectingTo = ValueNotifier(null);

  static disconnect() {
    currentTable.disconnect();
  }

  static connectToDevice(DiscoveredDevice device) {
    disconnect();
    connectingTo.value = device;
    print("BLE Connecting to ${device.name}");
    Stream<ConnectionStateUpdate> currentConnection = flutterReactiveBle.connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 5),
    );

    StreamSubscription<ConnectionStateUpdate>? currentConnectionStream;
    currentConnectionStream = currentConnection.listen((event) async {
      switch (event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            print("BLE Connecting Status to ${device.name}");

            connectingTo.value = device;
            currentTable.disconnect();
            break;
          }
        case DeviceConnectionState.connected:
          {
            print("BLE Connected Status to ${device.name}");
            connectingTo.value = null;
            await currentTable.connect(device, currentConnectionStream);
            scanSubscription?.cancel();
            clearScan();
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            print("BLE Disconnected Status to ${device.name}");
            connectingTo.value = null;
            currentTable.disconnect();
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            connectingTo.value = null;
            currentTable.disconnect();
            print("Disconnecting");
            break;
          }
        default:
          break;
      }
    });
  }

  static stopScan() {
    scanSubscription?.cancel();
  }

  static clearScan() {
    connectingTo.value = null;
    stopScan();
    deviceList.value.clear();
    deviceList.notifyListeners();
  }

  // i = stupid workaround b/c first time scanning sometimes fails and idk why so it just calls itself another time

  //TODO: remove if this doesnt work
  static startScan({int i = 1}) async {
    scanSubscription?.cancel();
    //print(connectedDevice);
    scanSubscription = flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      print(device.name);
      if (String.fromCharCodes(device.manufacturerData) == "Tottori") {
        if ((device.name).isNotEmpty) {
          print("AFDSGHJDFKHGAHGFAJDG  " + device.toString());
          if ((deviceList.value.map((e) => e.id).contains(device.id))) {
            deviceList.value[deviceList.value.indexWhere((e) => e.id == device.id)] = device;
          } else {
            deviceList.value.add(device);
          }
          deviceList.notifyListeners();
        }
      }
    });
    if (i > 0) {
      return startScan(i: i - 1);
    }
  }
}
