import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late VideoPlayerController _controller;
  Map<String, dynamic>? _jsonData;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    const flaskStreamUrl =
        "http://10.42.0.238:5000/stream_video"; // Flask API endpoint

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(flaskStreamUrl))
        ..initialize().then((_) {
          setState(() {});
          _controller.play();
        }).catchError((error) {
          _handleVideoError(error);
        });
    } catch (error) {
      _handleVideoError(error);
    }
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
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),
          const SizedBox(height: 16),
        ],
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
          if (_jsonData != null && _jsonData!['result'] == 'error')
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
