import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final selectedCow = Provider.of<CowProvider>(context).selectedCow;

    if (selectedCow == null) {
      return const Center(
        child: Text('No cow selected'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Records'),
      ),
      body: Center(
        child: Text(
          'Tracking Coordinates:\nX: ${selectedCow.x}, Y: ${selectedCow.y}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
