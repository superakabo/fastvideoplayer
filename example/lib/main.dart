import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fastvideoplayer/fast_video_player.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = FastVideoPlayerController.asset('assets/videos/file_example_MP4_480_1_5MG.mp4');

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
            body: Align(
              alignment: Alignment.topCenter,
              child: AspectRatio(
                aspectRatio: 1,
                child: FastVideoPlayer(
                  key: UniqueKey(),
                  autoPlay: false,
                  fit: BoxFit.cover,
                  autoDispose: true,
                  controller: controller,
                  placeholder: (progress) {
                    return Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white12,
                        value: progress,
                      ),
                    );
                  },
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
                  onPressed: () => setState(() {
                    controller = FastVideoPlayerController.network(
                      'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
                    );
                  }),
                ),
                FloatingActionButton.extended(
                  heroTag: 'Cached Network',
                  label: const Text('Cached Network Video'),
                  onPressed: () => setState(() {
                    controller = FastVideoPlayerController.network(
                      cache: true,
                      'https://download.samplelib.com/mp4/sample-5s.mp4',
                    );
                  }),
                ),
                FloatingActionButton.extended(
                  heroTag: 'Asset',
                  label: const Text('Load Asset Video'),
                  onPressed: () => setState(() {
                    controller = FastVideoPlayerController.asset(
                      'assets/videos/file_example_MP4_480_1_5MG.mp4',
                    );
                  }),
                ),
                FloatingActionButton.extended(
                  heroTag: 'File',
                  label: const Text('Select File Video'),
                  onPressed: () async {
                    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
                    if (file != null) {
                      setState(() {
                        controller = FastVideoPlayerController.file(file.path);
                      });
                    }
                  },
                ),
                FloatingActionButton.extended(
                  heroTag: 'Clear Cache',
                  label: const Text('Clear Cached Videos'),
                  onPressed: () async {
                    await DefaultCacheManager().emptyCache();
                    debugPrint('Cached videos cleared');
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
