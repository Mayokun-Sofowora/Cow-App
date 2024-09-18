import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:provider/provider.dart';
import 'package:fl_animated_linechart/fl_animated_linechart.dart';
import '../services/provider_service.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  TrackingPageState createState() => TrackingPageState();
}

class TrackingPageState extends State<TrackingPage> {
  @override
  void initState() {
    super.initState();
    _loadCowData();
  }

  void _loadCowData() {
    final cowProvider = Provider.of<CowProvider>(context, listen: false);
    if (cowProvider.startTimestamp != null &&
        cowProvider.endTimestamp != null) {
      final startTime =
          cowProvider.startTimestamp!.millisecondsSinceEpoch ~/ 1000;
      final endTime = cowProvider.endTimestamp!.millisecondsSinceEpoch ~/ 1000;
      cowProvider.loadCowData(startTime, endTime).then((_) {
        // Trigger a rebuild after loading data
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cowProvider = Provider.of<CowProvider>(context);

    final selectedCow = cowProvider.selectedCow;
    final selectedCowId = cowProvider.selectedCowId;
    final startTimestamp = cowProvider.startTimestamp;
    final endTimestamp = cowProvider.endTimestamp;
    final path = cowProvider.cowPaths;

    if (selectedCow == null ||
        selectedCowId == null ||
        startTimestamp == null ||
        endTimestamp == null) {
      return const Center(
        child: Text('No cow or time range selected'),
      );
    }

    // Create separate maps for X and Y coordinates
    Map<DateTime, double> xCoordinates = {};
    Map<DateTime, double> yCoordinates = {};
    List<DateTime> verticalMarkers = [];
    for (var point in path) {
      Vector3? position = point['position'] as Vector3?;
      String? timestamp = point['timestamp'] as String?;
      if (position != null && timestamp != null) {
        DateTime dateTime =
            DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
        xCoordinates[dateTime] = position.x;
        yCoordinates[dateTime] =
            position.z; // Using z for the y-axis in 2D view

        // Add a vertical marker every hour
        if (dateTime.minute == 0 && dateTime.second == 0) {
          verticalMarkers.add(dateTime);
        }
      }
    }

    LineChart? chart;
    if (xCoordinates.isNotEmpty && yCoordinates.isNotEmpty) {
      chart = LineChart.fromDateTimeMaps(
        [xCoordinates, yCoordinates],
        [Colors.blue, Colors.red],
        ["X coordinate", "Y coordinate"],
        tapTextFontWeight: FontWeight.bold,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Records'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.amberAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Selected Cow ID: $selectedCowId',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.green[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Time:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateTime.fromMillisecondsSinceEpoch(startTimestamp.millisecondsSinceEpoch).toLocal()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.green[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Time:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateTime.fromMillisecondsSinceEpoch(endTimestamp.millisecondsSinceEpoch).toLocal()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cow Path History (2D View)',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: chart != null
                        ? AnimatedLineChart(
                            chart,
                            key: UniqueKey(),
                            gridColor: Colors.black26,
                            toolTipColor: Colors.blueGrey,
                            legends: [
                              Legend(
                                title: "X coordinate",
                                color: Colors.blue,
                                icon: const Icon(Icons.location_on),
                              ),
                              Legend(
                                title: "Y coordinate",
                                color: Colors.red,
                                icon: const Icon(Icons.location_on),
                              ),
                            ],
                            showMarkerLines: true,
                            verticalMarker: verticalMarkers,
                            verticalMarkerColor: Colors.green.withOpacity(0.7),
                            verticalMarkerIcon: const [
                              Icon(Icons.access_time, color: Colors.green)
                            ],
                            iconBackgroundColor: Colors.white,
                            fillMarkerLines: true,
                            innerGridStrokeWidth: 0.5,
                            useLineColorsInTooltip: true,
                            showMinutesInTooltip: true,
                            tapText: (String traceName, double value,
                                String formattedDateTime) {
                              return "Position: $traceName\nValue: ${value.toStringAsFixed(2)}\nTime: $formattedDateTime";
                            },
                          )
                        : const Center(
                            child: Text('No data available for chart'),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Time period: ${endTimestamp.difference(startTimestamp).inMinutes} minutes',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
