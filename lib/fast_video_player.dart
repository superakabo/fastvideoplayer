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
  final Duration? seekTo;
  final FastVideoPlayerStrings strings;
  final VoidCallback? onTap;
  final Widget Function(double?)? placeholder;
  final bool autoDispose;
  final bool hidePlayerControls;

  const FastVideoPlayer({
    required this.controller,
    this.fit = BoxFit.none,
    this.clipBehavior = Clip.hardEdge,
    this.alignment = Alignment.center,
    this.mute = false,
    this.loop = true,
    this.autoPlay = false,
    this.captionOffset = Duration.zero,
    this.seekTo,
    this.onTap,
    this.strings = const FastVideoPlayerStrings(),
    this.autoDispose = false,
    this.hidePlayerControls = false,
    this.placeholder,
    super.key,
  });

  Future<void> _initiateController() async {
    controller.setCaptionOffset(captionOffset);
    await controller.setVolume(mute ? 0 : 1);
    await controller.setLooping(loop);
    if (seekTo != null) await controller.seekTo(seekTo!);
    if (!controller.value.isInitialized) await controller.initialize();
    if (autoPlay) await controller.play();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInitialized = useListenableSelector(controller, () => controller.value.isInitialized);

    /// Mark: widget lifecycle.
    /// initiate and dispose video player controller.
    useEffect(() {
      _initiateController();
      return (autoDispose) ? controller.dispose : null;
    }, [controller]);

    void toggleVideoPlayerControlVisibility() {
      if (!hidePlayerControls) {
        final visible = controller.playerControlsVisibilityNotifier.value;
        controller.playerControlsVisibilityNotifier.value = !visible;
      }
    }

    return Theme(
      data: theme.copyWith(
        iconTheme: theme.iconTheme.copyWith(
          color: Colors.white,
          shadows: [
            const BoxShadow(blurRadius: 1),
          ],
        ),
      ),
      child: Semantics(
        label: strings.semanticLabel,
        child: GestureDetector(
          onTap: onTap ?? toggleVideoPlayerControlVisibility,
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
              if (isInitialized && !hidePlayerControls)
                FastVideoPlayerControls(
                  controller,
                  strings,
                )
              else ...[
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
      ),
    );
  }
}
