import 'dart:async';

import '../disposable.dart';


/// Disposable wrapper for [StreamController] that calls
/// [StreamController.close] upon disposing.
final class DisposableStreamController<T> implements Disposable {
  /// Create new disposable for [controller].
  const DisposableStreamController(this.controller);

  /// Target controller.
  final StreamController<T> controller;

  @override
  void dispose() {
    unawaited(controller.close());
  }
}
