import 'package:fastvideoplayer/fastvideoplayer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
          seedColor: Colors.green,
        ),
      ),
      home: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Scaffold(
            body: Center(
              child: (filePath.isEmpty)
                  ? const Text('Select Video')
                  : FastVideoPlayer(
                      key: UniqueKey(),
                      autoPlay: true,
                      url: filePath,
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
