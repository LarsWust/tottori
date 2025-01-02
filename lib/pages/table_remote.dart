import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:tottori/classes/ble_connect.dart';
import 'package:tottori/classes/tottori_table_data.dart';
import 'package:tottori/classes/tottori_track.dart';
import 'package:tottori/components/connection_meter.dart';
import 'package:tottori/components/selectors/selectors.dart';
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
        child: /*FutureBuilder(
            future: currentUserData.ownedQueues.last.getData(),
            initialData: TottoriQueue.defaultData,
            builder: (context, snapshot) {
              return QueueView(
                queueData: snapshot.data!,
              );
            })*/
            Column(
      children: [
        TextButton(onPressed: () => BLEConnect.startScan(i: 5), child: const Text("Start Scan")),
        TextButton(onPressed: () => BLEConnect.stopScan(), child: const Text("Stop Scan")),
        TextButton(onPressed: () => BLEConnect.clearScan(), child: const Text("Clear Scan")),
        TextField(
          onSubmitted: (value) {
            currentTable.setAngSpeed(int.parse(value));
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.speed),
            hintText: 'Default 1500',
            labelText: 'Angle Speed',
          ),
        ),
        TextField(
          onSubmitted: (value) {
            currentTable.setDistSpeed(int.parse(value));
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.speed),
            hintText: 'Default 1500',
            labelText: 'Distance Speed',
          ),
        ),
        TextButton(
            onPressed: () {
              currentTable.fakeData();
            },
            child: const Text("Fake Table")),
        StreamBuilder(
            stream: currentTable.dataStream,
            initialData: currentTable.data,
            builder: (context, data) {
              return Column(
                children: [
                  Text(
                    data.data.toString(),
                    textScaleFactor: 0.65,
                  ),
                  TextButton.icon(
                    onPressed: () => currentTable?.togglePlay(),
                    label: const Text("Play/Pause"),
                    icon: Icon(data.data?.isPlaying == true ? Icons.pause : Icons.play_arrow),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await currentTable.playTrack(TottoriTrack((await selectAddingTracks(context))[0].uid));
                    },
                    label: const Text("Select Track"),
                    icon: Icon(data.data?.isPlaying == true ? Icons.pause : Icons.play_arrow),
                  ),
                ],
              );
            }),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: BLEConnect.deviceList,
            builder: (context, value, child) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: value.length,
                itemBuilder: (context, index) {
                  DiscoveredDevice device = value[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  device.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                                height: 12,
                                child: connectionMeter(device.rssi, 5),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          ValueListenableBuilder(
                            valueListenable: BLEConnect.connectingTo,
                            builder: (context, connectingTo, child) {
                              return Row(
                                children: [
                                  const SizedBox(
                                    width: 75,
                                    height: 75,
                                    child: Placeholder(),
                                  ),
                                  const Spacer(),
                                  connectingTo?.id != device.id
                                      ? (ValueListenableBuilder(
                                          valueListenable: currentTable.isConnectedNotifier,
                                          builder: (context, isConnected, _) {
                                            return isConnected && currentTable.device?.id == device.id
                                                ? TextButton(
                                                    onPressed: () {
                                                      BLEConnect.disconnect();
                                                    },
                                                    child: const Text("Disconnect"),
                                                  )
                                                : TextButton(
                                                    onPressed: () {
                                                      BLEConnect.connectToDevice(device);
                                                    },
                                                    child: const Text("Connect"),
                                                  );
                                          }))
                                      : const CircularProgressIndicator(),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    ));
  }
}
