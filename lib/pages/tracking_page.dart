import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cube/flutter_cube.dart';
import '../services/provider_service.dart';
import 'dart:math' as math;

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

    final path = cowProvider.cowPath;

    if (selectedCow == null ||
        selectedCowId == null ||
        startTimestamp == null ||
        endTimestamp == null) {
      return const Center(
        child: Text('No cow or time range selected'),
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
                      'Cow Path History',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 400, // Set a fixed height for the 3D cube
                      child: Container(
                          color: Colors.black12,
                          padding: const EdgeInsets.all(16.0),
                          child: Cube(
                            onSceneCreated: (Scene scene) {
                              if (kDebugMode) {
                                print(
                                    "Scene created. Path length: ${path.length}");
                              } // for testing purposes
                              final pathObject = Object();

                              if (path.isNotEmpty) {
                                for (int i = 0; i < path.length; i++) {
                                  final position = path[i];
                                  if (kDebugMode) {
                                    print(
                                        "Adding point at position: $position");
                                  }
                                  try {
                                    final sphere = Object(
                                      scale: Vector3(0.05, 0.05, 0.05),
                                      position: position,
                                      fileName:
                                          'assets/sphere.obj', // A 3D model for points
                                    );
                                    pathObject.children.add(sphere);

                                    // Add line between points to visualize path
                                    if (i < path.length - 1) {
                                      final nextPosition = path[i + 1];
                                      final midPoint =
                                          (position + nextPosition) * 0.5;
                                      final distance =
                                          (nextPosition - position).length;
                                      final direction = nextPosition - position;
                                      final rotation = Vector3(
                                          math.atan2(
                                              direction.y,
                                              math.sqrt(direction.x *
                                                      direction.x +
                                                  direction.z * direction.z)),
                                          math.atan2(-direction.x, direction.z),
                                          0);

                                      final line = Object(
                                        fileName: 'assets/line.obj',
                                        position: midPoint,
                                        scale: Vector3(0.01, distance, 0.01),
                                        rotation: rotation,
                                      );
                                      pathObject.children.add(line);
                                    }
                                  } catch (e) {
                                    if (kDebugMode) {
                                      print("Error adding object: $e");
                                    }
                                  }
                                }
                                scene.world.add(pathObject);
                              } else {
                                if (kDebugMode) {
                                  print(
                                      "Path is empty. Adding single stationary point.");
                                }
                                // Handle case when cow is stationary
                                pathObject.children.add(Object(
                                  position: Vector3(0, 0, 0),
                                  scale: Vector3(1.1, 1.1, 1.1),
                                  fileName: 'assets/sphere.obj',
                                ));
                                scene.world.add(pathObject);
                              }
                            },
                          )),
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}
