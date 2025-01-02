import 'package:flutter/material.dart';

Widget connectionMeter(int rssi, int collumns) {
  double perfectRSSI = -50;
  double rssiFactor = (rssi + 120) / (120 + perfectRSSI);
  if (rssi > 0) {
    rssiFactor = 0;
  }
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: collumns,
        separatorBuilder: (context, index) {
          return SizedBox(
            width: constraints.maxWidth / (collumns * 2),
          );
        },
        itemBuilder: (context, index) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: (index + 1) / collumns,
              child: Builder(
                builder: (context) {
                  Color color = Theme.of(context).dividerColor;
                  if ((index + 1) / collumns <= rssiFactor) {
                    color = Colors.green;
                  }
                  return Container(
                    color: color,
                    width: constraints.maxWidth / (collumns * 2),
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );
}
