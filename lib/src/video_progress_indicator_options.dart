import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProgressIndicatorOptions {
  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VideoProgressColors colors;

  /// When true, the widget will detect touch input and try to seek the video
  /// accordingly. The widget ignores such input when false.
  ///
  /// Defaults to false.
  final bool allowScrubbing;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  ///
  /// Defaults to `top: 5.0`.
  final EdgeInsets padding;

  const VideoProgressIndicatorOptions({
    this.colors = const VideoProgressColors(),
    required this.allowScrubbing,
    required this.padding,
  });
}
