import 'package:flutter/widgets.dart';

/// Keeps Flutter controls above a platform map on platforms that use the
/// framework's gesture arena for embedded views.
final class PlatformViewInterceptorStub extends StatelessWidget {
  /// Creates a platform-view-safe control surface.
  const PlatformViewInterceptorStub({required this.child, super.key});

  /// The control surface that must receive the pointer.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

typedef PlatformViewInterceptor = PlatformViewInterceptorStub;
