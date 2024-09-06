import 'package:cow_monitor/services/cow_repository.dart';
import 'package:cow_monitor/services/provider_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    final provider = Provider.of<CowProvider>(context, listen: false);
    final videoUrl = provider.currentStreamUrl;

    if (videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      )..initialize().then((_) {
          setState(() {});
          _controller.play();
        }).catchError((error) {
          _handleVideoError(error);
        });
    } else {
      setState(() {
        _jsonData = {
          'result': 'error',
          'message': 'Invalid video URL',
        };
      });
    }
  }

  Future<void> _fetchData() async {
    final provider = Provider.of<CowProvider>(context, listen: false);
    final timestamp = provider.currentTimestamp;

    final startTime = timestamp - 60; // 1 minute before
    final endTime = timestamp + 60; // 1 minute after

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

  void _handleVideoError(dynamic error) {
    if (kDebugMode) {
      print('Error initializing video: $error');
    }
    setState(() {
      _jsonData = {
        'result': 'error',
        'message': 'Failed to load video',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Cow Monitor',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildVideoSection(),
            _buildInfoSection(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      color: Colors.blueGrey[700],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Live Cow Stream',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Helvetica',
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            height: 300, // Fixed height for video container
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _controller.value.isInitialized
                ? _buildVideoPlayer()
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(_controller),
            if (_jsonData != null && _jsonData!['result'] == 'success')
              ..._buildBoundingBoxes(_jsonData!['data']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cow Activity',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700]),
          ),
          const SizedBox(height: 8),
          if (_jsonData != null && _jsonData!['result'] == 'success')
            ..._buildCowActivityList(_jsonData!['data'])
          else if (_jsonData != null && _jsonData!['result'] == 'error')
            Text(
              _jsonData!['message'],
              style: const TextStyle(color: Colors.red),
            )
          else
            const Text('Loading cow activity data...'),
        ],
      ),
    );
  }

  List<Widget> _buildCowActivityList(List<dynamic> data) {
    final cowProvider = Provider.of<CowProvider>(context);
    final selectedCowId = cowProvider.selectedCowId;

    return data.map((cow) {
      final id =
          selectedCowId ?? cow[0];
      final action = cow[4];
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(Icons.pets, color: Colors.blue[700]),
          title: Text('Cow #$id',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Action: $action'),
        ),
      );
    }).toList();
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
