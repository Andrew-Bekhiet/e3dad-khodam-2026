/// Why the camera last changed, so a surface can tell its own animation
/// apart from a movement the renderer already knows about.
enum CameraChangeOrigin {
  /// The app moved the camera; the renderer must be told to follow.
  app,

  /// The renderer moved the camera (a user gesture); the app is only
  /// catching up, and echoing it back would fight the gesture.
  renderer,
}
