import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:video_player/video_player.dart';

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
  final VideoPlayerOptions? videoPlayerOptions;
  final VideoPlayerController? controller;
  final Map<String, String> httpHeaders;
  final VideoFormat? formatHint;
  final String? package;

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
    this.videoPlayerOptions,
    this.formatHint,
    this.package,
    this.httpHeaders = const <String, String>{},
    this.controller,
    this.backgroundColor = Colors.black,
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
      );
    }

    if (url.startsWith('asset')) {
      return VideoPlayerController.asset(
        url,
        package: package,
        videoPlayerOptions: videoPlayerOptions,
      );
    }

    return VideoPlayerController.file(
      File(url),
      httpHeaders: httpHeaders,
      videoPlayerOptions: videoPlayerOptions,
    );
  }

  Future<VideoPlayerController> _initiateController() async {
    final tmpController = _createController();

    tmpController.setCaptionOffset(captionOffset);
    await tmpController.setClosedCaptionFile(closedCaptionFile);
    await tmpController.setVolume(mute ? 0 : 1);
    await tmpController.setLooping(loop);
    await tmpController.initialize();
    if (autoPlay) await tmpController.play();

    return tmpController;
  }

  @override
  Widget build(BuildContext context) {
    final videoController = useFuture(useMemoized(_initiateController)).data;
    useEffect(() => videoController?.dispose, const []);

    return ColoredBox(
      color: backgroundColor,
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
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
      ),
    );
  }
}
