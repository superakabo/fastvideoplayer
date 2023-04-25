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
    assert(uri.toString().isNotEmpty, 'uri cannot be an empty string');

    if (uri.toString().startsWith('file')) {
      return FastVideoPlayerController.file(
        File(uri.path),
        httpHeaders: httpHeaders,
        videoPlayerOptions: videoPlayerOptions,
        closedCaptionFile: closedCaptionFile,
      );
    }

    if (uri.toString().startsWith('asset')) {
      return FastVideoPlayerController.asset(
        uri.toString(),
        package: package,
        videoPlayerOptions: videoPlayerOptions,
        closedCaptionFile: closedCaptionFile,
      );
    }

    if (uri.toString().startsWith('http')) {
      return FastVideoPlayerController.network(
        uri.toString(),
        formatHint: formatHint,
        httpHeaders: httpHeaders,
        videoPlayerOptions: videoPlayerOptions,
        closedCaptionFile: closedCaptionFile,
      );
    }

    return FastVideoPlayerController.contentUri(
      uri,
      videoPlayerOptions: videoPlayerOptions,
      closedCaptionFile: closedCaptionFile,
    );
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

  FastVideoPlayerController.contentUri(
    Uri contentUri, {
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  }) : super.contentUri(
          contentUri,
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
        );
}
