import 'dart:math';
import 'package:cow_monitor/services/cow_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cube/flutter_cube.dart';
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
    // final List<Vector3> path = cowProvider.cowPath;
    final List<Vector3> path = cowProvider.getCowPath();



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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              _buildTrackingSection(context, selectedCow, path),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Cow Location:\nX: ${selectedCow.x}, Y: ${selectedCow.y}',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingSection(
    BuildContext context, Cow selectedCow, List<Vector3> path) {
  // if (path.isEmpty) {
  //   return const Center(child: Text('No path data available'));
  // }

  return SizedBox(
    height: 300, // Provide a fixed height for the Cube widget
    child: Cube(
      onSceneCreated: (Scene scene) {
        // Create a parent object to hold line segments
        final lineSegments = Object();

        for (int i = 0; i < path.length - 1; i++) {
          final startPoint = path[i];
          final endPoint = path[i + 1];
          
          // Calculate the distance and direction
          final distance = (endPoint - startPoint).length;
          final midPoint = (startPoint + endPoint) / 2;

          // Create a line segment as a cylinder
          lineSegments.children.add(Object(
            position: midPoint,
            scale: Vector3(0.1, distance / 2, 0.1), // Adjust the thickness and length
            rotation: Vector3(
              0,
              atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x),
              0,
            ),
            // You can customize the color or material here if needed
          ));
        }

        scene.world.add(lineSegments); // Add all line segments to the scene

        // Add the selected cow's position
        scene.world.add(Object(
          position: Vector3(selectedCow.x, selectedCow.y, 0.5),
          scale: Vector3(0.4, 0.4, 0.4),
        ));

        // Adjust camera position
        scene.camera.position.setValues(0, 5, 10); // Elevate the camera
        scene.update();
      },
    ),
  );
}

}
