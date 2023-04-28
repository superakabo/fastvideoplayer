import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

class FastVideoPlayerController extends VideoPlayerController {
  FastVideoPlayerController.asset(
    this._dataSource, {
    String? package,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
  })  : _dataSourceType = DataSourceType.asset,
        cache = false,
        super.asset(
          _dataSource,
          package: package,
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
        );

  FastVideoPlayerController.file(
    this._dataSource, {
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const <String, String>{},
  })  : _dataSourceType = DataSourceType.file,
        cache = false,
        super.file(
          File(_dataSource),
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
          httpHeaders: httpHeaders,
        );

  FastVideoPlayerController.network(
    this._dataSource, {
    this.cache = false,
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const <String, String>{},
  })  : _dataSourceType = DataSourceType.network,
        super.network(
          _dataSource,
          formatHint: formatHint,
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
          httpHeaders: httpHeaders,
        );

  final cacheManager = DefaultCacheManager();
  final cacheProgressNotifier = ValueNotifier<double?>(null);

  /// Mark: cache network video.
  final bool cache;

  /// Mark: Reference object for the cache download stream.
  /// Used to dispose the stream subscription.
  StreamSubscription<FileResponse>? _downloadStream;

  /// Mark: override the dataSource property to support
  /// the re-initialization of the controller with the cached dataSource.
  @override
  String get dataSource => _dataSource;
  String _dataSource;

  @override
  DataSourceType get dataSourceType => _dataSourceType;
  DataSourceType _dataSourceType;

  void _cacheVideo() {
    FileInfo? cachedFile;

    final stream = cacheManager.getFileStream(
      dataSource,
      headers: httpHeaders,
      withProgress: true,
    );

    void onDone() {
      _downloadStream?.cancel();
      if (cachedFile != null) {
        _initializeCachedVideo(cachedFile!);
      }
    }

    void onData(FileResponse response) {
      if (response is FileInfo) {
        cachedFile = response;
      }

      if (response is DownloadProgress) {
        cacheProgressNotifier.value = response.progress;
      }
    }

    _downloadStream = stream.listen(
      onData,
      onDone: onDone,
      cancelOnError: true,
    );
  }

  /// Mark: Wait for the precaching to complete and set the cached file path
  /// as the new dataSource. Revert to the original dataSource if it is null.
  /// Initialize the controller to use the cached dataSource.
  Future<void> _initializeCachedVideo(FileInfo fileInfo) {
    _dataSource = fileInfo.file.absolute.path;
    _dataSourceType = DataSourceType.file;
    return super.initialize();
  }

  /// Mark: Render the first frame of the video while precaching the remote video.
  /// Prevent video from being played until the precache is complete.
  Future<void> _precacheAndRenderFirstFrame() async {
    _cacheVideo();
    await super.initialize();
    value = value.copyWith(duration: Duration.zero, isInitialized: false);
    return;
  }

  @override
  Future<void> initialize() async {
    // Mark: first check and use cached file as the dataSource if it exists.
    if (cache) {
      final fileInfo = await cacheManager.getFileFromCache(dataSource);
      return (fileInfo == null) ? _precacheAndRenderFirstFrame() : _initializeCachedVideo(fileInfo);
    }
    return super.initialize();
  }

  @override
  Future<void> dispose() {
    cacheManager.dispose();
    cacheProgressNotifier.dispose();
    return super.dispose();
  }
}
