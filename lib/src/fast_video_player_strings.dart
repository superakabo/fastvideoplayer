class FastVideoPlayerStrings {
  final String play;
  final String pause;
  final String fullScreen;
  final String exitFullScreen;
  final String forward10Seconds;
  final String replay10Seconds;
  final String mute;
  final String unmute;

  const FastVideoPlayerStrings({
    this.play = 'Play',
    this.pause = 'Pause',
    this.fullScreen = 'Full screen',
    this.exitFullScreen = 'Exit full screen',
    this.forward10Seconds = 'Forward 10 seconds',
    this.replay10Seconds = 'Replay 10 seconds',
    this.mute = 'Mute',
    this.unmute = 'Unmute',
  });

  FastVideoPlayerStrings copyWith({
    String? play,
    String? pause,
    String? fullScreen,
    String? exitFullScreen,
    String? forward10Seconds,
    String? replay10Seconds,
    String? mute,
    String? unmute,
  }) {
    return FastVideoPlayerStrings(
      play: play ?? this.play,
      pause: pause ?? this.pause,
      mute: mute ?? this.mute,
      unmute: unmute ?? this.unmute,
      fullScreen: fullScreen ?? this.fullScreen,
      exitFullScreen: exitFullScreen ?? this.exitFullScreen,
      forward10Seconds: forward10Seconds ?? this.forward10Seconds,
      replay10Seconds: replay10Seconds ?? this.replay10Seconds,
    );
  }
}
