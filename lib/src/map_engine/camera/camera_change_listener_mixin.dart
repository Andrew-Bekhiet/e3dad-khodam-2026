import 'package:e3dad_khodam_2026/src/map_engine/camera/map_camera_controller.dart';
import 'package:flutter/widgets.dart';

/// The [MapCameraController] listener body both map surfaces need:
/// reposition markers for the moved camera, then push the camera to the
/// renderer only when the app moved it — echoing back a
/// renderer-originated movement would fight the gesture that produced
/// it.
///
/// A mixin rather than a duplicated method on each surface's `State`,
/// since the two implementations were, and would otherwise stay,
/// character-for-character identical.
mixin CameraChangeListenerMixin<T extends StatefulWidget> on State<T> {
  /// The controller this mixin listens to.
  MapCameraController get cameraController;

  /// Pushes [cameraController]'s current camera to the renderer.
  void pushCameraToRenderer();

  /// Registers this mixin as a [cameraController] listener; call once,
  /// typically from `initState`.
  void listenForCameraChanges() =>
      cameraController.addListener(_onCameraChanged);

  /// Unregisters the listener [listenForCameraChanges] added; call from
  /// `dispose`.
  void stopListeningForCameraChanges() =>
      cameraController.removeListener(_onCameraChanged);

  void _onCameraChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      // Rebuild only: the moved camera is read straight from
      // `cameraController.camera` inside `build()`.
    });
    if (cameraController.origin == CameraChangeOrigin.app) {
      pushCameraToRenderer();
    }
  }
}
