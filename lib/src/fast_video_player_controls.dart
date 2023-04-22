import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

import 'utilities/fast_video_player_strings.dart';

class FastVideoPlayerControls extends StatelessWidget {
  final FastVideoPlayerStrings strings;
  final VideoPlayerController videoController;

  const FastVideoPlayerControls({
    required this.videoController,
    required this.strings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: Row(
            children: [
              _PlayPauseButton(videoController, strings),
              _VolumeButton(videoController, strings),
              _PlaybackTime(videoController),
              const Spacer(),
              _Replay10Button(videoController, strings),
              _Forward10Button(videoController, strings),
              _FullScreenButton(videoController, strings),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeButton extends HookWidget {
  final VideoPlayerController controller;
  final FastVideoPlayerStrings strings;

  const _VolumeButton(
    this.controller,
    this.strings,
  );

  @override
  Widget build(BuildContext context) {
    final volume = useListenableSelector(controller, () => controller.value.volume);
    final isMuted = (volume == 0.0);
    final icon = (isMuted) ? Icons.volume_off : Icons.volume_up;

    return IconButton(
      splashRadius: 20,
      icon: Icon(icon),
      onPressed: () => controller.setVolume(isMuted ? 1.0 : 0.0),
      tooltip: (isMuted) ? strings.unmute : strings.mute,
    );
  }
}

class _PlayPauseButton extends HookWidget {
  final VideoPlayerController controller;
  final FastVideoPlayerStrings strings;

  const _PlayPauseButton(
    this.controller,
    this.strings,
  );

  @override
  Widget build(BuildContext context) {
    final isPlaying = useListenableSelector(controller, () => controller.value.isPlaying);
    final icon = isPlaying ? Icons.pause : Icons.play_arrow;

    return IconButton(
      splashRadius: 20,
      icon: Icon(icon),
      onPressed: (isPlaying) ? controller.pause : controller.play,
      tooltip: (isPlaying) ? strings.pause : strings.play,
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
            style: theme.primaryTextTheme.titleSmall?.copyWith(
              shadows: [
                const BoxShadow(blurRadius: 1),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Replay10Button extends StatelessWidget {
  final VideoPlayerController controller;
  final FastVideoPlayerStrings strings;

  const _Replay10Button(
    this.controller,
    this.strings,
  );

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.replay_10),
      splashRadius: 20,
      tooltip: strings.replay10Seconds,
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
  final FastVideoPlayerStrings strings;

  const _Forward10Button(
    this.controller,
    this.strings,
  );

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 20,
      icon: const Icon(Icons.forward_10),
      tooltip: strings.forward10Seconds,
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
  final FastVideoPlayerStrings strings;

  const _FullScreenButton(
    this.controller,
    this.strings,
  );

  @override
  Widget build(BuildContext context) {
    final isFullScreenRef = useState(false);
    final icon = (isFullScreenRef.value) ? Icons.fullscreen_exit : Icons.fullscreen;

    return IconButton(
      splashRadius: 20,
      icon: Icon(icon),
      tooltip: (isFullScreenRef.value) ? strings.exitFullScreen : strings.fullScreen,
      onPressed: () {
        isFullScreenRef.value = !isFullScreenRef.value;

        if (isFullScreenRef.value) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }
      },
    );
  }
}
