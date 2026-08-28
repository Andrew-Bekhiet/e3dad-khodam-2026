import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Places an invisible browser element behind Flutter controls so the map's
/// HTML platform view cannot receive their pointer events.
final class PlatformViewInterceptorWeb extends StatelessWidget {
  /// Creates a platform-view-safe control surface.
  const PlatformViewInterceptorWeb({required this.child, super.key});

  /// The control surface that must receive the pointer.
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Positioned.fill(
        child: HtmlElementView.fromTagName(
          tagName: 'div',
          isVisible: false,
          onElementCreated: (element) {
            (element as web.HTMLElement).addEventListener(
              'mousedown',
              (web.Event event) {
                event.preventDefault();
              }.toJS,
            );
          },
        ),
      ),
      child,
    ],
  );
}

typedef PlatformViewInterceptor = PlatformViewInterceptorWeb;
