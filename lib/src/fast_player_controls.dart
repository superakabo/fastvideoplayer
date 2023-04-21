import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

class FastPlayerControls extends StatelessWidget {
  final VideoPlayerController controller;

  const FastPlayerControls({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: Row(
            children: [
              _PlayPauseButton(controller),
              _VolumeButton(controller),
              _PlaybackTime(controller),
              const Spacer(),
              _Replay10Button(controller),
              _Forward10Button(controller),
              _FullScreenButton(controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeButton extends HookWidget {
  final VideoPlayerController controller;
  const _VolumeButton(this.controller);

  @override
  Widget build(BuildContext context) {
    final volume = useListenableSelector(controller, () => controller.value.volume);
    final isMuted = (volume == 0.0);
    final icon = isMuted ? Icons.volume_off : Icons.volume_up;

    return IconButton(
      splashRadius: 20,
      icon: Icon(icon),
      onPressed: () => controller.setVolume(isMuted ? 1.0 : 0.0),
    );
  }
}

class _PlayPauseButton extends HookWidget {
  final VideoPlayerController controller;
  const _PlayPauseButton(this.controller);

  @override
  Widget build(BuildContext context) {
    final isPlaying = useListenableSelector(controller, () => controller.value.isPlaying);
    final icon = isPlaying ? Icons.pause : Icons.play_arrow;

    return IconButton(
      splashRadius: 20,
      icon: Icon(icon),
      onPressed: isPlaying ? controller.pause : controller.play,
    );
  }
}

class _PlaybackTime extends StatelessWidget {
  final VideoPlayerController controller;
  const _PlaybackTime(this.controller);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, __) {
        final theme = Theme.of(context);
        final currentTime = value.position.toString().substring(2, 7);
        final totalTime = value.duration.toString().substring(2, 7);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text.rich(
            TextSpan(
              text: currentTime,
              children: [
                const TextSpan(text: ' / '),
                TextSpan(text: totalTime),
              ],
            ),
            style: theme.primaryTextTheme.titleSmall,
          ),
        );
      },
    );
  }
}

class _Replay10Button extends StatelessWidget {
  final VideoPlayerController controller;
  const _Replay10Button(this.controller);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 20,
      icon: const Icon(Icons.replay_10),
      onPressed: () {
        final position = controller.value.position;
        final newPosition = Duration(seconds: max(0, position.inSeconds - 10));
        controller.seekTo(newPosition);
      },
    );
  }
}

class _Forward10Button extends StatelessWidget {
  final VideoPlayerController controller;
  const _Forward10Button(this.controller);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 20,
      icon: const Icon(Icons.forward_10),
      onPressed: () {
        final videoDuration = controller.value.duration.inSeconds;
        final position = controller.value.position;
        final newPosition = Duration(seconds: min(videoDuration, position.inSeconds + 10));
        controller.seekTo(newPosition);
      },
    );
  }
}

class _FullScreenButton extends HookWidget {
  final VideoPlayerController controller;
  const _FullScreenButton(this.controller);

  @override
  Widget build(BuildContext context) {
    final isFullScreen = useState(false);
    final icon = (isFullScreen.value) ? Icons.fullscreen_exit : Icons.fullscreen;

    return IconButton(
      splashRadius: 20,
      icon: Icon(icon),
      onPressed: () {
        isFullScreen.value = !isFullScreen.value;
      },
    );
  }
}
