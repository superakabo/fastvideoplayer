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
  final cacher = DefaultCacheManager();

  /// Mark: video download progress notifier when caching network video.
  final cacheProgressNotifier = ValueNotifier<double?>(null);

  /// Mark: toggles the visibility of the video player controls.
  final playerControlsVisibilityNotifier = ValueNotifier(true);

  /// Mark: cache network video.
  final bool cache;

  /// Mark: use to check if video has completed caching and can be played.
  final isReady = ValueNotifier(false);

  /// Mark: video download completer
  final _completer = Completer<FileInfo?>();

  /// Mark: automatically play video after the controller is initialized.
  bool _autoPlay = false;

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
  Future<FileInfo?> _downloadVideo() {
    final stream = cacher.getFileStream(
      dataSource,
      headers: httpHeaders,
      withProgress: true,
    );

    _downloadStream = stream.listen((response) {
      if (response is FileInfo) {
        _downloadStream?.cancel();
        if (!_completer.isCompleted) {
          _completer.complete(response);
        }
      }

      if (response is DownloadProgress) {
        cacheProgressNotifier.value = response.progress;
      }
    });

    return _completer.future;
  }

  /// Mark: Wait for the precaching to complete if the video is not cached.
  /// The new cached video path is set as the new dataSource.
  Future<void> _initializeCachedVideo(FileInfo? fileInfo) async {
    if (fileInfo == null) {
      // Mark: Render the first video frame.
      await super.initialize();

      // Mark: re-initialize controller to play from a file.
      value = value.copyWith(duration: Duration.zero);
      final newFileInfo = await _downloadVideo();
      if (newFileInfo != null) {
        _dataSource = newFileInfo.file.uri.toString();
      }
    } else {
      _dataSource = fileInfo.file.uri.toString();
    }

    _dataSourceType = DataSourceType.file;
    return await super.initialize();
  }

  @override
  Future<void> initialize() async {
    if (cache && dataSource.startsWith('http')) {
      final fileInfo = await cacher.getFileFromCache(dataSource);
      await _initializeCachedVideo(fileInfo);
    }

    if (cache && dataSource.startsWith('file')) {
      _dataSourceType = DataSourceType.file;
      await super.initialize();
    }

    if (!cache) {
      await super.initialize();
    }

    isReady.value = true;
    if (_autoPlay) await play();
  }

  Future<void> autoPlay() async {
    _autoPlay = true;
  }

  /// Mark: Deny playback for network videos with cache option enabled
  /// until the video is downloaded and cached.
  @override
  Future<void> play() async {
    if (isReady.value) {
      return super.play();
    }
  }

  @override
  Future<void> dispose() {
    _downloadStream?.cancel();
    _downloadStream = null;
    _completer.complete(null);
    isReady.dispose();
    cacheProgressNotifier.dispose();
    playerControlsVisibilityNotifier.dispose();
    return super.dispose();
  }
}
