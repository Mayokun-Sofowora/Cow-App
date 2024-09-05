import 'package:cow_monitor/services/cow_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  final String videoUrl;
  final int timestamp;
  const HomePage({super.key, required this.videoUrl, required this.timestamp});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late VideoPlayerController _controller;
  Map<String, dynamic>? _jsonData;
  final CowRepository _cowRepository = CowRepository();

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _fetchData();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  Future<void> _fetchData() async {
    final startTime = widget.timestamp - 60; // 1 minute before
    final endTime = widget.timestamp + 60; // 1 minute after

    try {
      final objectIds = await _cowRepository.fetchCowIds(startTime, endTime);
      final objectDataList = await _getCowData(objectIds, startTime, endTime);

      setState(() {
        _jsonData = {
          'result': 'success',
          'data': objectDataList,
        };
      });
    } catch (e) {
      _handleFetchError(e);
    }
  }

  Future<List<List<dynamic>>> _getCowData(
      List<int> objectIds, int startTime, int endTime) async {
    final List<List<dynamic>> objectDataList = [];
    for (var objectId in objectIds) {
      List<Cow> cowDataList =
          await _cowRepository.fetchCowData(startTime, endTime, objectId);
      objectDataList.addAll(cowDataList.map((cowData) => [
            cowData.x, // X position
            cowData.y, // Y position
            cowData.w, // Width
            cowData.h, // Height
            cowData.action, // Action
          ]));
    }
    return objectDataList;
  }

  void _handleFetchError(dynamic error) {
    if (kDebugMode) {
      print('Error fetching data: $error');
    }
    setState(() {
      _jsonData = {
        'result': 'error',
        'message': error.toString(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: _controller.value.isInitialized
            ? _buildVideoPlayer()
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildVideoPlayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 4), // Thick white border
            borderRadius: BorderRadius.circular(8),
            color: Colors.black54, // Darkish background for the container
          ),
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(_controller),
                if (_jsonData != null && _jsonData!['result'] == 'success')
                  ..._buildBoundingBoxes(_jsonData!['data']),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Cow Stream',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // Title style
        ),
        if (_jsonData != null && _jsonData!['result'] == 'error')
          Text(
            _jsonData!['message'],
            style: const TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  List<Widget> _buildBoundingBoxes(List<dynamic> data) {
    return data.map((box) {
      final id = box[0];
      final x = double.tryParse(box[1].toString()) ?? 0;
      final y = double.tryParse(box[2].toString()) ?? 0;
      final w = double.tryParse(box[3].toString()) ?? 0;
      final h = double.tryParse(box[4].toString()) ?? 0;
      final action = box[5];

      return Positioned(
        left: x,
        top: y,
        width: w,
        height: h,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Center(
            child: Text(
              '$id: $action',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }).toList();
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: Icon(
        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
