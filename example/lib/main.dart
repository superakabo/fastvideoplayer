import 'package:fastvideoplayer/fastvideoplayer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.withOpacity(0.3),
        body: const Center(
          child: FastVideoPlayer(
            autoPlay: true,
            url: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
          ),
        ),
      ),
    );
  }
}
