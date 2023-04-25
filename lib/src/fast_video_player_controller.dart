import 'dart:io';

import 'package:video_player/video_player.dart';

class FastVideoPlayerController extends VideoPlayerController {
  factory FastVideoPlayerController(
    Uri uri, {
    String? package,
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const <String, String>{},
  }) {
    assert(uri.scheme.isNotEmpty, 'uri cannot be an empty string');
    assert(uri.path.isNotEmpty, 'uri path cannot be an empty string');

    switch (uri.scheme) {
      case 'http':
      case 'https':
        return FastVideoPlayerController.network(
          uri.toString(),
          formatHint: formatHint,
          httpHeaders: httpHeaders,
          videoPlayerOptions: videoPlayerOptions,
          closedCaptionFile: closedCaptionFile,
        );

      case 'asset':
        return FastVideoPlayerController.asset(
          uri.toString(),
          package: package,
          videoPlayerOptions: videoPlayerOptions,
          closedCaptionFile: closedCaptionFile,
        );

      default:
        return FastVideoPlayerController.file(
          File(uri.toString()),
          httpHeaders: httpHeaders,
          videoPlayerOptions: videoPlayerOptions,
          closedCaptionFile: closedCaptionFile,
        );
    }
  }

  FastVideoPlayerController.network(
    String dataSource, {
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const <String, String>{},
  }) : super.network(
          dataSource,
          formatHint: formatHint,
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
          httpHeaders: httpHeaders,
        );

  FastVideoPlayerController.file(
    File file, {
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const <String, String>{},
  }) : super.file(
          file,
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
          httpHeaders: httpHeaders,
        );

  FastVideoPlayerController.asset(
    String dataSource, {
    String? package,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  }) : super.asset(
          dataSource,
          package: package,
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
        );
}
