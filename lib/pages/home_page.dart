import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Image? currentFrame;
  List<dynamic> bboxData = [];

  @override
  void initState() {
    super.initState();
    streamVideo("http://140.116.86.242:25582/stream_video");
  }


  Future<void> streamVideo(String url) async {
    try {
      final response =
          await http.Client().send(http.Request('GET', Uri.parse(url)));
      print("Response received. Status code: ${response.statusCode}");
      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        print("Received line: $line");
        if (line.startsWith('data: ')) {
          final jsonData = line.substring(6);
          print("Parsed JSON data: $jsonData");
          final data = jsonDecode(jsonData);

          setState(() {
            currentFrame = Image.memory(base64Decode(data['image']),
                gaplessPlayback: true);
            bboxData = data['bbox'];
          });
          print("Frame updated. Bounding boxes: ${bboxData.length}");
        }
        }, onError: (error) {
      print("Error in stream: $error");
    });
    } catch (e) {
      print("Error streaming video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cow Monitor'),
      ),
      body: Center(
        child: currentFrame != null
            ? Stack(
                alignment: Alignment.center, // Center the stack contents
                children: [
                  currentFrame!, // Video stream
                  CustomPaint(
                    painter: BoundingBoxPainter(bboxData),
                    size: Size.infinite, // Ensure CustomPaint takes full size
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<dynamic> bboxes;

  BoundingBoxPainter(this.bboxes);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw bounding boxes
    for (var bbox in bboxes) {
      final trackId = bbox[0];
      final x = bbox[1].toDouble();
      final y = bbox[2].toDouble();
      final w = bbox[3].toDouble();
      final h = bbox[4].toDouble();
      final action = bbox[5];

      // Adjust the bounding box size and position if necessary
      final adjustedX = x - 70;
      final adjustedY = y - 70;
      final adjustedW = w / 5;
      final adjustedH = h / 10;

      // Define bounding box color
      final paint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0; // Increase stroke width for better visibility

      // Ensure the adjusted dimensions are positive
      if (adjustedW > 0 && adjustedH > 0) {
        // Draw rectangle
        canvas.drawRect(Rect.fromLTWH(adjustedX, adjustedY, adjustedW, adjustedH), paint);

        // Draw label
        final textSpan = TextSpan(
          text: 'ID: $trackId, Action: $action',
          style: const TextStyle(color: Colors.green, fontSize: 12),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(adjustedX, adjustedY - 10)); // Adjust label position if needed
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Repaint every time the image updates
  }
}

