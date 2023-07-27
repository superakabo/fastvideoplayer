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
        super.networkUrl(
          Uri.parse(_dataSource),
          formatHint: formatHint,
          closedCaptionFile: closedCaptionFile,
          videoPlayerOptions: videoPlayerOptions,
          httpHeaders: httpHeaders,
        );

  /// Mark: manage cached videos.
  final cacheManager = DefaultCacheManager();

  /// Mark: video download progress notifier when caching network video.
  final cacheProgressNotifier = ValueNotifier<double?>(null);

  /// Mark: toggles the visibility of the video player controls.
  final playerControlsVisibilityNotifier = ValueNotifier(true);

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

  final _cacheCompleter = Completer<FileInfo>();

  /// Mark: download and cache video while
  /// updating the download progress notifier
  Future<FileInfo> _downloadVideo() {
    final stream = cacheManager.getFileStream(
      dataSource,
      headers: httpHeaders,
      withProgress: true,
    );

    _downloadStream = stream.listen((response) {
      if (response is FileInfo) {
        _downloadStream?.cancel();
        _cacheCompleter.complete(response);
      }

      if (response is DownloadProgress) {
        cacheProgressNotifier.value = response.progress;
      }
    });

    return _cacheCompleter.future;
  }

  /// Mark: Wait for the precaching to complete and set the cached file path
  /// as the new dataSource. Revert to the original dataSource if it is null.
  /// Initialize the controller to use the cached dataSource.
  Future<void> _initializeCachedVideo(FileInfo? fileInfo) async {
    await super.initialize();

    value = value.copyWith(
      duration: Duration.zero,
      isPlaying: false,
      isInitialized: false,
    );

    if (fileInfo == null) {
      final newFileInfo = await _downloadVideo();
      _dataSource = newFileInfo.file.uri.toString();
    } else {
      _dataSource = fileInfo.file.uri.toString();
    }

    _dataSourceType = DataSourceType.file;
    return super.initialize();
  }

  @override
  Future<void> initialize() async {
    /// Mark: first check and use cached video path as the dataSource if it exists.
    if (cache && dataSource.startsWith('http')) {
      final fileInfo = await cacheManager.getFileFromCache(dataSource);
      return _initializeCachedVideo(fileInfo);
    }

    /// Mark: If [cache = true] and [dataSource starts with file://]
    /// in instances where the controller is restored from cache or
    /// the same controller is reused.
    if (cache && dataSource.startsWith('file')) {
      _dataSourceType = DataSourceType.file;
      return super.initialize();
    }

    return super.initialize();
  }

  @override
  Future<void> dispose() {
    cacheProgressNotifier.dispose();
    playerControlsVisibilityNotifier.dispose();
    return super.dispose();
  }
}
