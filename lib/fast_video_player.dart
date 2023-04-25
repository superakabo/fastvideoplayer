import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

import 'src/fast_video_player_controller.dart';
import 'src/fast_video_player_controls.dart';
import 'src/fast_video_player_strings.dart';

export 'src/fast_video_player_controller.dart';
export 'src/fast_video_player_controls.dart';
export 'src/fast_video_player_strings.dart';

class FastVideoPlayer extends HookWidget {
  final FastVideoPlayerController controller;
  final BoxFit fit;
  final Clip clipBehavior;
  final AlignmentGeometry alignment;
  final bool mute;
  final bool loop;
  final bool autoPlay;
  final Duration captionOffset;
  final Duration seekTo;
  final bool showPlayerControls;
  final ThemeData? theme;
  final bool cacheVideo;
  final FastVideoPlayerStrings strings;
  final VoidCallback? onTap;
  final bool keepAlive;
  final bool autoDispose;

  const FastVideoPlayer({
    required this.controller,
    this.fit = BoxFit.none,
    this.clipBehavior = Clip.hardEdge,
    this.alignment = Alignment.center,
    this.mute = false,
    this.loop = true,
    this.autoPlay = false,
    this.captionOffset = Duration.zero,
    this.seekTo = Duration.zero,
    this.showPlayerControls = true,
    this.theme,
    this.onTap,
    this.cacheVideo = true,
    this.strings = const FastVideoPlayerStrings(),
    this.keepAlive = false,
    this.autoDispose = false,
    super.key,
  });

  Future<VideoPlayerController> _initiateController() async {
    print('loading url -> ${controller.dataSource}');
    controller.setCaptionOffset(captionOffset);
    await controller.setVolume(mute ? 0 : 1);
    await controller.setLooping(loop);
    await controller.seekTo(seekTo);
    await controller.initialize();
    if (autoPlay) await controller.play();
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = theme ?? Theme.of(context);

    final videoController = useFuture(
      useMemoized(_initiateController),
    ).data;

    useAutomaticKeepAlive(wantKeepAlive: keepAlive);

    useEffect(() {
      if (autoDispose) {
        return videoController?.dispose;
      }
      return null;
    }, const []);

    return Theme(
      data: themeData.copyWith(
        iconTheme: themeData.iconTheme.copyWith(
          color: Colors.white,
          shadows: [
            const BoxShadow(blurRadius: 1),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () {
          if (onTap != null) onTap?.call();
        },
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: clipBehavior,
          children: [
            if (videoController == null)
              ColoredBox(
                color: themeData.colorScheme.tertiaryContainer,
                child: const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              )
            else ...[
              FittedBox(
                fit: fit,
                alignment: alignment,
                clipBehavior: clipBehavior,
                child: SizedBox(
                  width: videoController.value.size.width,
                  height: videoController.value.size.height,
                  child: VideoPlayer(videoController),
                ),
              ),
              if (showPlayerControls)
                FastVideoPlayerControls(
                  videoController,
                  strings,
                ),
            ]
          ],
        ),
      ),
    );
  }
}
