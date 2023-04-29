# fastvideoplayer

This is the official intuitive video player with cache support for FastAd. 
It reduces the boilerplate code required to use a video player. 

To use fast video player,

1. create an instance of FastVideoPlayerController.

```dart
 final controller = FastVideoPlayerController.asset('assets/videos/file_example_MP4_480_1_5MG.mp4');
```

2. Add the FastVideoPlayer widget

```dart
 FastVideoPlayer(
      autoPlay: false,
      fit: BoxFit.cover,
      autoDispose: true,
      controller: controller,
      placeholder: (progress) {
        return Center(
          child: CircularProgressIndicator.adaptive(
            backgroundColor: Colors.white12,
            value: progress,
          ),
        );
      },
    );
```