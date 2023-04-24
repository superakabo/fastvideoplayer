import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fastvideoplayer/fast_video_player.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    String filePath = '';

    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Scaffold(
            backgroundColor: Colors.grey.shade700,
            body: Center(
              child: (filePath.isEmpty)
                  ? Text(
                      'Select Video',
                      style: Theme.of(context).primaryTextTheme.headlineSmall,
                    )
                  : AspectRatio(
                      aspectRatio: 1,
                      child: FastVideoPlayer(
                        key: UniqueKey(),
                        autoPlay: false,
                        url: filePath,
                      ),
                    ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'Network',
                  label: const Text('Load Network Video'),
                  onPressed: () {
                    filePath = 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';
                    setState(() {});
                  },
                ),
                FloatingActionButton.extended(
                  heroTag: 'Asset',
                  label: const Text('Load Asset Video'),
                  onPressed: () {
                    filePath = 'assets/videos/file_example_MP4_480_1_5MG.mp4';
                    setState(() {});
                  },
                ),
                FloatingActionButton.extended(
                  heroTag: 'File',
                  label: const Text('Select File Video'),
                  onPressed: () async {
                    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
                    if (file != null) {
                      filePath = file.path;
                      print('file path: ${file.path}');
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
