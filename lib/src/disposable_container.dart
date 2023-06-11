import 'package:meta/meta.dart';

import 'disposable.dart';


/// Container that automatically disposes all objects in [disposables] list.
/// Mentioned list is cached on moment of object creation, so if your
/// [disposables] changes over time, override getter with a `final` field with
/// modifiable list.
/// 
/// **CAUTION**: any [Disposable] of [disposables] **MUST** not have strong
/// references to `this` parent, otherwise it will cause memory-leak.
abstract class DisposableContainer {
  /// Construct container and attach to [Disposable.finalizer].
  DisposableContainer() {
    // We cache result and use it to detach finalizer
    // Otherwise it will cause memory leak, because finalizer creates
    // strong reference to the argument which will be passed to callback.
    final _disposables = disposables;
    Disposable.finalizer.attach(this, _disposables, detach: _disposables);
  }

  /// List of [Disposable] objects that must be disposed when this container
  /// lost it's last reference.
  @protected
  List<Disposable> get disposables => [];
}
