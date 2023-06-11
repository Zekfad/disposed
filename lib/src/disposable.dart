import 'package:meta/meta.dart';


/// Disposable interface.
abstract interface class Disposable {
  /// Dispose this object.
  /// **NOTICE**: This method can be called multiple times.
  @mustCallSuper
  void dispose() {}

  /// Finalizer that does the heavy lifting.
  @internal
  static final finalizer = Finalizer(_finalize);

  /// Finalizer callback.
  static void _finalize(List<Disposable> disposables) {
    for (final disposable in disposables)
      disposable.dispose();
    finalizer.detach(disposables);
  }
}
