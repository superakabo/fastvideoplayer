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

  /// Mark: Indicates whether or not the video has been loaded and is ready to play.
  /// Use this in place of [value.isInitialized].
  final canPlayNotifier = ValueNotifier(false);

  /// Mark: manage cached videos.
  final cacheManager = DefaultCacheManager();

  /// Mark: video download progress notifier when caching network video.
  final cacheProgressNotifier = ValueNotifier<double?>(null);

  /// Mark: toggles the visibility of the video player controls.
  final playerControlsVisibilityNotifier = ValueNotifier(true);

  /// Mark: cache network video.
  final bool cache;

  /// Mark: cached video file info.
  FileInfo? _fileInfo;

  /// Mark: used to determine if user attempted to
  /// play video before it was done caching.
  /// This will allow the video to be played once the caching
  /// is complete. In a sense, it mimicks the auto play behaviour
  /// through the use of a controller.
  bool _prematureCachePlayback = false;

  /// Mark: Reference object for the cache download stream.
  /// Used to dispose the stream subscription.
  StreamSubscription<FileResponse>? _downloadStream;

  /// Mark: override the dataSource property to support
  /// the re-initialization of the controller with the cached dataSource.
  @override
  String get dataSource => _dataSource;
  String _dataSource;

  /// Mark: The place from which the video is fetched or loaded from.
  @override
  DataSourceType get dataSourceType => _dataSourceType;
  DataSourceType _dataSourceType;

  /// Mark: download and cache video while
  /// updating the download progress notifier
  Future<FileInfo> _downloadVideo() {
    final completer = Completer<FileInfo>();

    final stream = cacheManager.getFileStream(
      dataSource,
      headers: httpHeaders,
      withProgress: true,
    );

    _downloadStream = stream.listen((response) {
      if (response is FileInfo) {
        _downloadStream?.cancel();
        completer.complete(response);
      }

      if (response is DownloadProgress) {
        cacheProgressNotifier.value = response.progress;
      }
    });

    return completer.future;
  }

  /// Mark: Wait for the precaching to complete if the video is not cached.
  /// The new cached video path is set as the new dataSource.
  Future<void> _initializeCachedVideo() async {
    if (_fileInfo == null) {
      /// Mark: Render the first video frame,
      /// unset initialization status and video duration
      super.initialize().whenComplete(() {
        value = value.copyWith(duration: Duration.zero);
      });

      _fileInfo = await _downloadVideo();
      _dataSource = _fileInfo!.file.uri.toString();
    } else {
      _dataSource = _fileInfo!.file.uri.toString();
    }

    _dataSourceType = DataSourceType.file;
    return await super.initialize();
  }

  @override
  Future<void> initialize() async {
    /// Mark: first check and use cached video path as the dataSource if it exists.
    if (cache && dataSource.startsWith('http')) {
      canPlayNotifier.value = false;
      _fileInfo = await cacheManager.getFileFromCache(dataSource);
      await _initializeCachedVideo();
      canPlayNotifier.value = true;
      if (_prematureCachePlayback) play();
    }

    /// Mark: If [cache = true] and [dataSource starts with file://]
    /// in instances where the controller is restored from cache or
    /// the same controller is reused.
    else if (cache && dataSource.startsWith('file')) {
      canPlayNotifier.value = false;
      _dataSourceType = DataSourceType.file;
      await super.initialize();
      canPlayNotifier.value = true;
      if (_prematureCachePlayback) play();
    }

    canPlayNotifier.value = false;
    await super.initialize();
    canPlayNotifier.value = true;
  }

  /// Mark: Deny playback for network videos with cache option enabled
  /// until the video is downloaded and cached.
  @override
  Future<void> play() async {
    if (cache) {
      if (_fileInfo != null) {
        _prematureCachePlayback = false;
        return super.play();
      } else {
        _prematureCachePlayback = true;
      }
    } else {
      return super.play();
    }
  }

  @override
  Future<void> dispose() {
    _fileInfo = null;
    _downloadStream = null;
    canPlayNotifier.dispose();
    cacheProgressNotifier.dispose();
    playerControlsVisibilityNotifier.dispose();
    return super.dispose();
  }
}
