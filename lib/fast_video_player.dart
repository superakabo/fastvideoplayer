import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

import 'src/fast_video_player_controller.dart';
import 'src/fast_video_player_controls.dart';
import 'src/fast_video_player_strings.dart';

export 'src/fast_video_player_controls.dart';
export 'src/fast_video_player_strings.dart';
export 'src/fast_video_player_controller.dart';

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
  final FastVideoPlayerStrings strings;
  final VoidCallback? onTap;
  final Widget Function(double?)? placeholder;
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
    this.onTap,
    this.strings = const FastVideoPlayerStrings(),
    this.autoDispose = false,
    this.placeholder,
    super.key,
  });

  Future<void> _initiateController() async {
    controller.setCaptionOffset(captionOffset);
    await controller.setVolume(mute ? 0 : 1);
    await controller.setLooping(loop);
    await controller.seekTo(seekTo);
    await controller.initialize();
    if (autoPlay) await controller.play();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInitialized = useListenableSelector(controller, () => controller.value.isInitialized);

    useEffect(() {
      _initiateController();
      return (autoDispose) ? controller.dispose : null;
    }, const []);

    return Theme(
      data: theme.copyWith(
        iconTheme: theme.iconTheme.copyWith(
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
            FittedBox(
              fit: fit,
              alignment: alignment,
              clipBehavior: clipBehavior,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
            if (isInitialized) ...[
              if (showPlayerControls)
                FastVideoPlayerControls(
                  controller,
                  strings,
                ),
            ] else ...[
              if (placeholder != null)
                ValueListenableBuilder<double?>(
                  valueListenable: controller.cacheProgressNotifier,
                  builder: (_, progress, __) {
                    return placeholder!(progress);
                  },
                ),
            ]
          ],
        ),
      ),
    );
  }
}
