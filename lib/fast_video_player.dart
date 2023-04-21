import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

import 'src/fast_player_controls.dart';

class FastVideoPlayer extends HookWidget {
  final BoxFit fit;
  final Clip clipBehavior;
  final double viewportAspectRatio;
  final AlignmentGeometry alignment;
  final Color backgroundColor;
  final String url;
  final bool mute;
  final bool loop;
  final bool autoPlay;
  final Future<ClosedCaptionFile>? closedCaptionFile;
  final Duration captionOffset;
  final Duration seekTo;
  final VideoPlayerOptions? videoPlayerOptions;
  final VideoPlayerController? controller;
  final Map<String, String> httpHeaders;
  final VideoFormat? formatHint;
  final String? package;
  final bool showPlayerControls;
  final ThemeData? theme;

  const FastVideoPlayer({
    required this.url,
    this.viewportAspectRatio = 1,
    this.fit = BoxFit.cover,
    this.clipBehavior = Clip.antiAlias,
    this.alignment = Alignment.center,
    this.mute = false,
    this.loop = true,
    this.autoPlay = false,
    this.closedCaptionFile,
    this.captionOffset = Duration.zero,
    this.seekTo = Duration.zero,
    this.videoPlayerOptions,
    this.formatHint,
    this.package,
    this.httpHeaders = const <String, String>{},
    this.controller,
    this.backgroundColor = Colors.black,
    this.showPlayerControls = true,
    this.theme,
    super.key,
  }) : assert(url.length > 0, 'url cannot be an empty string');

  VideoPlayerController _createController() {
    if (controller != null) {
      return controller!;
    }

    if (url.startsWith('http')) {
      return VideoPlayerController.network(
        url,
        formatHint: formatHint,
        httpHeaders: httpHeaders,
        videoPlayerOptions: videoPlayerOptions,
        closedCaptionFile: closedCaptionFile,
      );
    }

    if (url.startsWith('asset')) {
      return VideoPlayerController.asset(
        url,
        package: package,
        videoPlayerOptions: videoPlayerOptions,
        closedCaptionFile: closedCaptionFile,
      );
    }

    return VideoPlayerController.file(
      File(url),
      httpHeaders: httpHeaders,
      videoPlayerOptions: videoPlayerOptions,
      closedCaptionFile: closedCaptionFile,
    );
  }

  Future<VideoPlayerController> _initiateController() async {
    final tmpController = _createController();

    tmpController.setCaptionOffset(captionOffset);
    await tmpController.setVolume(mute ? 0 : 1);
    await tmpController.setLooping(loop);
    await tmpController.seekTo(seekTo);
    await tmpController.initialize();

    if (autoPlay) await tmpController.play();

    return tmpController;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = theme ?? Theme.of(context);

    final videoController = useFuture(useMemoized(_initiateController)).data;
    useEffect(() => videoController?.dispose, const []);

    return Theme(
      data: themeData.copyWith(
        iconTheme: themeData.iconTheme.copyWith(
          color: Colors.white,
        ),
      ),
      child: ColoredBox(
        color: backgroundColor,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: fit,
                alignment: alignment,
                clipBehavior: clipBehavior,
                child: SizedBox(
                  width: videoController?.value.size.width ?? 1,
                  height: videoController?.value.size.height ?? 1,
                  child: (videoController == null)
                      ? const Center(child: CircularProgressIndicator.adaptive())
                      : VideoPlayer(videoController),
                ),
              ),
              if (showPlayerControls && videoController != null)
                FastPlayerControls(
                  controller: videoController,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
