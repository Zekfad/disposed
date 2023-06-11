/// Disposed library provides wrappers for automatic objects disposal
/// utilizing [Finalizer].
/// 
/// Using this package you can create object destructors.
/// 
/// Some catches:
/// 
/// Inner [Disposable] objects of [DisposableContainer] **MUST** not have strong
/// references to parent container, failed to follow this rule will cause
/// _memory leak_ and object would not only be never disposed, but also
/// remain in memory as long as program is running.
library disposed;

import 'disposable.dart';

export 'disposable.dart';
export 'disposables.dart';
